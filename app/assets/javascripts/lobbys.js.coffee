class @LoginsClass
  constructor: (url, useWebsocket) ->
    # これがソケットのディスパッチャー
    @dispatcher = new WebSocketRails(url, useWebsocket)
    # イベントを監視
    @bindEvents()
    console.log(@dispatcher)

  bindEvents: () =>
    # 送信ボタンが押されたらサーバへメッセージを送信
    #    $('#send').on 'click', @sendMessage
    # サーバーからnew_messageを受け取ったらreceiveMessageを実行
    @dispatcher.bind 'receive_message', @receiveMessage

  sendMessage: (event) =>
    # サーバ側にsend_messageのイベントを送信
    # オブジェクトでデータを指定
    user_name = $('#username').val()
    msg_body = $('#msgbody').val()
    #@dispatcher.trigger 'receive_message', { name: user_name }
    @dispatcher.trigger 'login_user', { name: user_name }

  receiveMessage: (message) =>
    # 受け取ったデータをappend
    $('.players').append "<li class=\"user\"> #{message.user_name} </li>"
    console.log(message)

$ ->
  window.loginsClass = new LoginsClass($('.player').data('uri'), true)
  @sendMessage
  console.log('send')