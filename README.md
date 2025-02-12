# BeeInnovative Client Software

## Installation
To install the BeeInnovative Client software, run the following command:

```bash
apt -y install wget && cd /tmp && wget https://raw.githubusercontent.com/Project4-0S1/beeInnovativeInstaller/refs/heads/main/clientinstaller.sh && chmod +x clientinstaller.sh && ./clientinstaller.sh "API_URL='https://beeinnovative.azurewebsites.net'" "RELAY_GPIO=23" "ALERT_GPIO=23" "BEEHIVE_LATITUDE=51.16109694916157" "BEEHIVE_LONGITUDE=4.961227393192176" "CLIENT_ID=REPLACEME" "CLIENT_SECRET=REPLACEME" "AUTH_URL=https://bee-innovative.eu.auth0.com/oauth/token"
```

### Important:
Make sure to replace the `REPLACEME` fields with your actual `CLIENT_ID` and `CLIENT_SECRET` values before running the script.

