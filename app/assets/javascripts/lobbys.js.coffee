class @LobbysClass
  constructor: (url, useWebsocket) ->
    console.log('constructors')
    # これがソケットのディスパッチャー
    @dispatcher = new WebSocketRails(url, useWebsocket)
    @sendMessage()
    # イベントを監視
    @bindEvents()
    console.log(@dispatcher)

  bindEvents: () =>
    # サーバーからnew_messageを受け取ったらreceiveMessageを実行
    @dispatcher.bind 'login_user', @receiveMessage

  sendMessage: (event) =>
    console.log('sendMessage')
    # サーバ側にsend_messageのイベントを送信
    # オブジェクトでデータを指定
    user_name = $('#myname').data('name')
    @dispatcher.trigger 'login_user', user_name

  receiveMessage: (message) =>
    console.log('receiveMessage')
    my_name = $('#myname').data('name')
    console.log(my_name)
    if message == my_name
      return
    else
      # 受け取ったデータをappend
      $('.players').append "<li class=\"user\"> #{message} </li>"
      console.log(message)
    

$ ->
  ws = new LobbysClass('herpes.nagoya:3000/websocket', true)
