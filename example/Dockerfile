FROM ghcr.io/dependabot/dependabot-updater-core

USER dependabot

COPY --chown=dependabot:dependabot example $DEPENDABOT_HOME/example
COPY --chown=dependabot:dependabot common $DEPENDABOT_HOME/common
COPY --chown=dependabot:dependabot updater $DEPENDABOT_HOME/dependabot-updater
