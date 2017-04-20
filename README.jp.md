[English version of this document](./README.md)

# SkyWay Peer 認証サンプル

このリポジトリにはPeerを認証するためのクレデンシャルの生成方法がわかるサンプルがあります。

## クレデンシャルの形式

`new Peer()` の `option` 引数に入る `credential` は下記の形式のJavaScriptオブジェクトです。

```javascript
{
  authToken: <string>,
  ttl: <number>,
  timestamp: <number>
}
```

### ttl

`ttl` はクレデンシャルの有効期限で、切れたらSkyWayサーバへの接続が切れます。
`ttl` の単位は秒で、600（10分）から90000（25時間）の間である必要があります。

### timestamp

`timestamp` は現在時刻のUnixタイムスタンプ（秒）です。

**注: 未来の時刻のタイムスタンプは拒否される。**

### authToken

`peerId`、`timestamp`、`ttl`とAppの`secretkey`を利用して計算される`peerId`用の認証トークンです。
`secretkey`は開発者ダッシュボードのApp画面から取得できます。

`$timestamp:$ttl:$peerId`の文字列にAppの`secretkey`を秘密鍵として利用して、HMAC-SHA256アルゴリズミを利用して計算します。

計算されたハッシュはBase64形式である必要があります。


## サンプルの利用方法

サンプルサーバの動作手順は各プログラミング言語の名前がついてるフォルダーに入っているREADMEに記載されています。

サンプルを実行する前に、`Config section`に入ってる`secretkey`変数を開発者ダッシュボードから取得した物に変更する必要があります。

クライアントからサーバに渡されるユーザIDとセッショントークンが有効か確認するために`checkSessionToken()`または`check_session_token()`関数を実装してもいいです。
サンプルではこの機能は実装されていなくて、常に有効なトークンと判断されます。
サンプルではセッショントークンを確認する事になっているけど、パスワードなどで任意な認証手段を利用できます。

サンプルサーバが起動したら http://localhost:8080/authenticate 宛てに`POST`リクエストを投げます。

リクエストは`application/x-www-form-urlencoded`形式で`peerId`と`sessionToken`パラメータを設定する必要があります。

下記の[例：JavaScriptとJQueryを利用したリクエスト](#例javascriptとjqueryを利用したリクエスト)を参照してください。
または[クライアントスクリプトのサンプル](#クライアントスクリプトのサンプル)に記載されてる手順に沿って、クライアントアプリのサンプルを利用してください。

### 例：JavaScriptとJQueryを利用したリクエスト

```javascript
$.post('http://localhost:8080/authenticate',
  {
    peerId: 'TestPeerID',
    sessionToken: '4CXS0f19nvMJBYK05o3toTWtZF5Lfd2t6Ikr2lID'
  }, function(credential) {
    var peer = new Peer('TestPeerID', {
      apikey: apikey,
      credential: credential
    });
    
    peer.on('open', function() {
      // ...
    });
  }).fail(function() {
    alert('Peer Authentication Failed');
  });
```

### クライアントスクリプトのサンプル

HTML/JavaScriptのクライアント認証サンプルが`client/`フォルダーに入ってます。

下記のコマンドを利用して、クライアントファイルをアクセス可能にします。
```bash
$ cd client
$ python -m SimpleHTTPServer 8000
```

サンプルのサーバのどれかが動作している状態で、http://localhost:8000 にアクセスして、`Get Credential`を押したら認証クレデンシャルが取得されます。
