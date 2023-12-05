function aup() {
  netstat -aon | findstr ":$1" | findstr "LISTENING"
}
