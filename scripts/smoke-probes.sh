# Navidrome：sso=proxy（Remote-User 代登录）；Subsonic 接口经网关；清单没有 mcp。
SSO=proxy
MCP=0

web_assert() { grep -qi 'navidrome'; }   # 标准输入：SPA 首页 HTML 含应用名

identity_check() { # Subsonic getUser：认出主人且是管理员
  local ping user
  ping="$(dweb "/rest/ping.view?v=1.16.1&c=wonton-smoke&f=json")" || { echo "ping 失败：$ping"; return 1; }
  grep -q '"status":"ok"' <<<"$ping" || { echo "ping 不是 ok：$ping"; return 1; }
  user="$(dweb "/rest/getUser.view?v=1.16.1&c=wonton-smoke&f=json&username=$SMOKE_OWNER")" ||
    { echo "getUser 失败：$user"; return 1; }
  jq -e --arg u "$SMOKE_OWNER" \
    '.["subsonic-response"].user.username == $u and .["subsonic-response"].user.adminRole == true' <<<"$user" >/dev/null ||
    { echo "getUser 不是主人的管理员账号：$user"; return 1; }
}
