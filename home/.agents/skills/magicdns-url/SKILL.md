---
name: magicdns-url
description: "Use whenever you are about to tell the user a URL of a server running on this machine (localhost, 127.0.0.1, 0.0.0.0, a dev/preview server port): give it as the short Tailscale MagicDNS name (`<host>:<port>`) instead of localhost. Also use when a MagicDNS / ts.net URL does not open. Use for: localhost, 127.0.0.1, devサーバーのURL, ポート番号, URL教えて, 別端末で見る, スマホで確認, MagicDNS, Tailscale, ts.net."
---

# MagicDNS URL

このマシンで動いているサーバーの URL をユーザーに伝えるときは、`localhost` ではなく Tailscale の MagicDNS の短い名前（`<host>:<port>`）で書く。別端末（スマホなど）からそのまま開けるようにするため。

## Procedure

### 1. MagicDNS 名を取る

App Store 版なので CLI はアプリバンドル内にある（`tailscale` はインタラクティブシェルのエイリアス）。

```sh
/Applications/Tailscale.app/Contents/MacOS/Tailscale status --json \
  | jq -r '"\(.BackendState) \(.Self.DNSName | split(".")[0])"'
```

出力は `<BackendState> <host>`。`<host>` はサーバーが動いているマシン（このコマンドを実行したマシン）の名前で、ユーザーが見ている端末の名前ではない。ホスト名は覚えず、毎回これで取る。

### 2. 外から届くか確認する

```sh
lsof -iTCP:<port> -sTCP:LISTEN -P -n
```

- `*:<port>` なら届く
- `127.0.0.1:<port>` / `[::1]:<port>` はループバックのみで、MagicDNS 名では開けない。その場合は localhost の URL を伝え、`--host` などで公開する方法を添える
- Vite / Astro は `Host` ヘッダを検査する。`curl -H "Host: <host>:<port>" http://localhost:<port>/` が 403 なら `server.allowedHosts` に `<host>` が要る

### 3. 伝える

`http://<host>:<port>/<path>` の形で書く。`.ts.net` 付きの長い名前や localhost の URL は併記しない。

## Tailscale が Running でないとき

`BackendState` が `Stopped` などなら URL は開けない。URL は短い名前で書いたうえで、止まっていることを必ず添える。勝手に起動はせず、`open -a Tailscale` を提案する。

App Store 版は Always On が無効だと、**アプリを終了（⌘Q）しただけで VPN も止まる**。「止めた覚えがない」ときはまずこれを疑う。確認はシステムログで行う（zsh では `log` が組み込みなので `/usr/bin/log` と書く）。

```sh
/usr/bin/log show --last 2d --style compact \
  --predicate 'process == "Tailscale" OR process == "IPNExtension"' \
  | grep -E "Handling Quit AppleEvent|stopTunnel|App termination beginning"
```

`Handling Quit AppleEvent` の直後に `stopTunnel: "userInitiated"` があれば、アプリ終了が原因。
