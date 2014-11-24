class @LobbysClass
  constructor: (url, useWebsocket) ->
    console.log('constructors')
    # これがソケットのディスパッチャー
    @dispatcher = new WebSocketRails(url, useWebsocket)
    # イベントを監視
    @bindEvents()
    @sendMessage('login')
    console.log(@dispatcher)

  bindEvents: () =>
    $('#logout').on 'click', @sendMessage 'logout'
    # サーバーからmessageを受け取ったらreceiveMessageを実行
    @dispatcher.bind 'login_user', @receiveMessage

  sendMessage: (event) =>
    # サーバ側にsend_messageのイベントを送信
    # オブジェクトでデータを指定
    console.log("event: " + event)
    
    user_name = $('#myname').data('name')
    @dispatcher.trigger 'login_user', user_name
  
  receiveMessage: (message) =>
    console.log('receiveMessage')
    console.log(message.users)
    
    my_name = $('#myname').data('name')
    console.log(my_name)
    if message.my_name == my_name
      # 通知されたユーザ名が自分だったら追加しません
      return
    else
      users_html = "<h2>ログイン中ユーザ</h2>"
      message.users.forEach (e) ->
        users_html += "<li class=\"user\">" + e.name + "</li>"

      # ユーザ一覧表示
      console.log(users_html)
      $('.players').html(users_html)

$ ->
  ws = new LobbysClass($('.players').data('uri'), true)