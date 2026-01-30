#!/bin/bash
set -e

SOCKS_PORT=1080
PASS="Civicboy2542ehev"
USERS="azure locethuser"

PUBLIC_IP=$(curl -s ifconfig.me)
IFACE=$(ip route get 1 | awk '{print $5; exit}')

apt update -y
apt install -y dante-server curl

for U in $USERS; do
  id "$U" >/dev/null 2>&1 || useradd -r -s /usr/sbin/nologin "$U"
  echo "$U:$PASS" | chpasswd
done

cat > /etc/danted.conf <<EOF
logoutput: syslog
internal: 0.0.0.0 port = ${SOCKS_PORT}
external: ${IFACE}
method: username
user.notprivileged: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
}
EOF

systemctl enable danted
systemctl restart danted

{
  echo "azure:${PUBLIC_IP}:${SOCKS_PORT}:azure:${PASS}"
  echo "locethuser:${PUBLIC_IP}:${SOCKS_PORT}:locethuser:${PASS}"
} > /root/socks5.txt
