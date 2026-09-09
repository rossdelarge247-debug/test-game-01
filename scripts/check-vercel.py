#!/usr/bin/env python3
"""Read-only Vercel connection diagnosis. Never print credentials or API bodies."""
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request


def report(message):
    print(message, flush=True)
    summary = os.environ.get("GITHUB_STEP_SUMMARY")
    if summary:
        with open(summary, "a", encoding="utf-8") as output:
            output.write(message + "\n\n")


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def lookup(token, project, team=None):
    url = "https://api.vercel.com/v9/projects/" + urllib.parse.quote(project, safe="")
    if team:
        url += "?" + urllib.parse.urlencode({"teamId": team})
    request = urllib.request.Request(url, headers={
        "Authorization": "Bearer " + token,
        "Accept": "application/json",
    }, method="GET")
    try:
        with urllib.request.build_opener(NoRedirect).open(request, timeout=20) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        # Vercel may mask an authorization failure as 404. Do not print its body.
        return error.code, {}
    except (urllib.error.URLError, TimeoutError, ValueError):
        return 0, {}


def main():
    report("Vercel connection check (read-only; no deployment)")
    values = {}
    malformed = False
    for name in ("VERCEL_TOKEN", "VERCEL_ORG_ID", "VERCEL_PROJECT_ID"):
        raw_value = os.environ.get(name, "")
        # Vercel identifiers cannot contain whitespace anywhere. Copy/paste
        # can insert a line break inside them; validate the result via the API.
        value = raw_value.strip() if name == "VERCEL_TOKEN" else re.sub(r"\s+", "", raw_value)
        if raw_value != value:
            report("NORMALIZED: Removed copy/paste whitespace from " + name + ".")
        values[name] = value
        if not value:
            report("FAIL: " + name + " is missing.")
            malformed = True
        elif any(char.isspace() for char in value):
            report("FAIL: " + name + " contains whitespace or a newline. Save only the raw value.")
            malformed = True
        elif value.startswith(('\"', "'")) or value.endswith(('\"', "'")):
            report("FAIL: " + name + " includes quotation marks. Save only the raw value.")
            malformed = True
    for name, prefix in (("VERCEL_ORG_ID", "team_"), ("VERCEL_PROJECT_ID", "prj_")):
        if values[name] and not re.fullmatch(prefix + r"[A-Za-z0-9]+", values[name]):
            report("FAIL: " + name + " is not a " + prefix + " identifier. Check for a name, URL or swapped IDs.")
            malformed = True
    if malformed:
        return 1

    token, team, project = (values[key] for key in ("VERCEL_TOKEN", "VERCEL_ORG_ID", "VERCEL_PROJECT_ID"))
    status, data = lookup(token, project, team)
    report("Configured project/team lookup: HTTP " + str(status))
    if status == 200:
        if data.get("id") != project or data.get("accountId") != team:
            report("FAIL: API response does not match the configured project/team pair.")
            return 1
        if data.get("name") != "test-game-01":
            report("FAIL: IDs resolve to a different project, not test-game-01.")
            return 1
        report("PASS: Token can read test-game-01 using the configured project and team IDs. Investigate CLI deployment separately if it still fails.")
        if "--export-env" in sys.argv:
            # Mask normalized values before later steps can display env headers.
            # GitHub consumes add-mask commands and hides their payloads.
            env_file = os.environ.get("GITHUB_ENV")
            if not env_file:
                report("FAIL: --export-env requires a GitHub Actions environment file.")
                return 1
            with open(env_file, "a", encoding="utf-8") as output:
                for name, value in values.items():
                    print("::add-mask::" + value, flush=True)
                    output.write(name + "=" + value + "\n")
        return 0
    if status == 401:
        report("FAIL: Vercel rejected authentication. Replace VERCEL_TOKEN with a valid, unexpired token.")
        return 1
    if status not in (403, 404):
        report("INCONCLUSIVE: Vercel/network error. No credentials or API response bodies were logged.")
        return 1

    by_name_status, by_name = lookup(token, "test-game-01", team)
    report("Project-name lookup in configured team: HTTP " + str(by_name_status))
    if by_name_status == 200 and by_name.get("id") != project:
        report("FAIL: VERCEL_PROJECT_ID does not match test-game-01 in the configured team. Team/token access works.")
        return 1

    scoped_status, scoped = lookup(token, project)
    report("Project lookup using token's default scope: HTTP " + str(scoped_status))
    if scoped_status == 200 and scoped.get("accountId") != team:
        report("FAIL: VERCEL_ORG_ID differs from the project's owning account/team returned by Vercel.")
    elif scoped_status == 200:
        report("FAIL: Token can read this project without an explicit team, but the explicit-team request was rejected. Check token scope and CLI team handling.")
    else:
        report("UNRESOLVED: Vercel denies or cannot find this project with the supplied token. IDs, token scope, account membership or SSO access may be responsible. No secret values were exposed.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
