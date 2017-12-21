  require 'Qt'
  require './encryption'
  require './message'
  require 'rest-client'
  require 'json'

class QtApp < Qt::Widget

  slots 'zaloguj()'

    def initialize
        super

        setWindowTitle "Logowanie"

        init_ui

        setFixedSize(560, 600)
        setStyleSheet("background-color:
                       qlineargradient(x1: 0, y1:1.2, x2:0, y2:0,
                       stop:0 #00CDAA, stop:1 #004E40);")

        show
    end
end

  def init_ui

    loginButt = Qt::PushButton.new "Login", self
    quitButt = Qt::PushButton.new "Wyjdz", self

    loginButt.resize 80, 30
    loginButt.move 200, 500

    quitButt.resize 80, 30
    quitButt.move 300, 500

    connect(loginButt, SIGNAL('clicked()'), self, SLOT('zaloguj()'))
    connect(quitButt, SIGNAL('clicked()'), $qApp, SLOT('quit()'))

    loginLabel = Qt::Label.new 'Login: ', self
    loginLabel.setFont Qt::Font.new "Impact", 11
    loginLabel.setStyleSheet("background-color: #009A80;
                             border-style: solid;
                             border-width:1px;
                             border-radius:3px;
                             border-color: #D9FFF8;
                             max-width:100px;
                             max-height:30px;
                             min-width:27px;
                             min-height:27px;")
    passwdLabel = Qt::Label.new 'Password: ', self
    passwdLabel.setFont Qt::Font.new "Impact", 11
    passwdLabel.setStyleSheet("background-color: #009A80;
                             border-style: solid;
                             border-width:1px;
                             border-radius:3px;
                             border-color: #D9FFF8;
                             max-width:100px;
                             max-height:30px;
                             min-width:27px;
                             min-height:27px;")

    loginLabel.move 100, 350
    passwdLabel.move 70, 400

    @loginEdit = Qt::LineEdit.new self
    @passwd = Qt::LineEdit.new self
    @passwd.setEchoMode(2)

    @loginEdit.resize 250, 30
    @loginEdit.move 170, 350

    @passwd.resize 250, 30
    @passwd.move 170, 400

  end

  def zaloguj

    checkIfValid(@loginEdit, @passwd)

  end

  def checkIfValid(login, password)

    counter = 0
    login = login.text
    password = password.text

    # connect to server
    users = 'http://138.68.173.185/cryptochat/product/users.php'
    response = RestClient.get(users)
    parsed_users = JSON.parse(response)

    # checking how many users we have in database
    x = parsed_users["records"].length

    # checking if user is in our database
    (0...x).each do |i|
      if(parsed_users["records"][i]["login"] == login && parsed_users["records"][i]["password"] == password)
        counter = 1
      end
    end

    if counter == 1
      system('./cryptoChat.rb')
      exit
    else
        Qt::MessageBox.about self, 'About', 'Wrong login and/or password. Try again.'
    end
  end

app = Qt::Application.new ARGV
QtApp.new
app.exec
