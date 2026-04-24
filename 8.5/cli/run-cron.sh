set -e

shutdown_cron() {
  set +e
  echo "[SHUTDOWN] Shutting down cron"
  kill $cronpid $tailpid
  wait $cronpid $tailpid
  exit $?
}

trap "shutdown_cron" HUP INT QUIT TERM USR1

cron -f &
cronpid=$!
echo "[STARTUP] Cron PID: $cronpid"
touch /var/log/cron.log
tail -f -n0 /var/log/cron.log &
tailpid=$!
wait $cronpid $tailpid
