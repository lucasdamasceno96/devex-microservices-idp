#!/usr/bin/env bash
set -e

REPO_URL="${GIT_REPO_URL:-https://github.com/lucasdamasceno96/devex-microservices-idp.git}"
REPO_PATH="${IDP_REPO_PATH:-/app/repo}"
GIT_USER="${GIT_USER:-idp-portal}"
GIT_EMAIL="${GIT_EMAIL:-idp-portal@devex-microservices-idp.local}"
GIT_TOKEN="${GIT_TOKEN:-}"

if [ ! -d "${REPO_PATH}/.git" ]; then
    echo "Cloning repository..."
    if [ -n "${GIT_TOKEN}" ]; then
        REPO_URL=$(echo "${REPO_URL}" | sed "s|https://|https://x-access-token:${GIT_TOKEN}@|")
    fi
    git clone --depth=1 "${REPO_URL}" "${REPO_PATH}"
fi

cd "${REPO_PATH}"
git config user.name "${GIT_USER}"
git config user.email "${GIT_EMAIL}"

if [ -n "${GIT_TOKEN}" ]; then
    REPO_URL_WITH_TOKEN=$(echo "${REPO_URL}" | sed "s|https://|https://x-access-token:${GIT_TOKEN}@|")
    git remote set-url origin "${REPO_URL_WITH_TOKEN}"
fi

git pull origin main 2>/dev/null || true

echo "Repository ready at ${REPO_PATH}"

exec streamlit run /app/app.py --server.port=8501 --server.address=0.0.0.0
