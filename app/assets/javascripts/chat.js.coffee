class @ChatClass
  constructor: (url, useWebsocket) ->
    # これがソケットのディスパッチャー
    @dispatcher = new WebSocketRails(url, useWebsocket)
    # イベントを監視
    @bindEvents()
    console.log(@dispatcher)

  bindEvents: () =>
    # 送信ボタンが押されたらサーバへメッセージを送信
    $('#send').on 'click', @sendMessage
    # サーバーからnew_messageを受け取ったらreceiveMessageを実行
    @dispatcher.bind 'receive_message', @receiveMessage

  sendMessage: (event) =>
    # サーバ側にsend_messageのイベントを送信
    # オブジェクトでデータを指定
    user_name = $('#username').val()
    msg_body = $('#msgbody').val()
    @dispatcher.trigger 'receive_message', { name: user_name , body: msg_body }
    $('#msgbody').val('')

  receiveMessage: (message) =>
    # 受け取ったデータをappend
    $('#chat').append "#{message.name} : #{message.body}<br/>"
    console.log(message)

$ ->
  window.chatClass = new ChatClass($('#chat').data('uri'), true)