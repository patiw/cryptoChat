  require 'Qt'
  require './encryption'
  require './message'
  require 'rest-client'
  require 'json'

class QtApp < Qt::Widget

  slots 'zaloguj()', 'signup()'

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
    signupButt = Qt::PushButton.new "Sign Up", self
    quitButt = Qt::PushButton.new "Wyjdz", self

    buttonStyle = "QPushButton {
                    background-color: #009A80;
                    border-style: solid;
                    border-width:1px;
                    border-radius:10px;
                    border-color: #D9FFF8;
                    max-width:100px;
                    max-height:50px;
                    min-width:30px;
                    min-height:30px;
                   }
                   QPushButton:pressed {
                    background-color: #004E40;
                    color: yellow;
                   }"

    loginButt.setFont Qt::Font.new "Impact", 12
    loginButt.setStyleSheet(buttonStyle)

    signupButt.setFont Qt::Font.new "Impact", 12
    signupButt.setStyleSheet(buttonStyle)

    quitButt.setFont Qt::Font.new "Impact", 12
    quitButt.setStyleSheet(buttonStyle)

    loginButt.resize 80, 30
    loginButt.move 200, 500

    signupButt.resize 80, 30
    signupButt.move 250, 200

    quitButt.resize 80, 30
    quitButt.move 300, 500

    connect(loginButt, SIGNAL('clicked()'), self, SLOT('zaloguj()'))
    connect(signupButt, SIGNAL('clicked()'), self, SLOT('signup()'))
    connect(quitButt, SIGNAL('clicked()'), $qApp, SLOT('quit()'))

    smallLabel = "background-color: none;
                  color: #0C2917;
                  max-width:100px;
                  max-height:30px;
                  min-width:27px;
                  min-height:27px;"

    loginLabel = Qt::Label.new 'Login: ', self
    loginLabel.setFont Qt::Font.new "Impact", 11
    loginLabel.setStyleSheet(smallLabel)

    funnyLabel = Qt::Label.new 'Still not having an account?', self
    funnyLabel.setFont Qt::Font.new "Impact", 20
    funnyLabel.setStyleSheet("background-color: none;
                              color: #0C2917")

    passwdLabel = Qt::Label.new 'Password: ', self
    passwdLabel.setFont Qt::Font.new "Impact", 11
    passwdLabel.setStyleSheet(smallLabel)

    loginLabel.move 100, 350
    funnyLabel.move 100, 150
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
        @response_serverid = parsed_users["records"][i]["serverID"]
      end
    end

    if counter == 1
      start_string = './cryptoChat.rb ' << @response_serverid

      exec(start_string)
      exit
    else
      Qt::MessageBox.about self, 'Trouble!', 'Wrong login and/or password. Try again.'
    end
  end

  def signup

    # made two separated windows for register, will change in future
    one = Qt::InputDialog.getText self, "Sign Up",
        "Enter your login"
    # cosmetic things
        if one == nil
          one = 0
        end
    two = Qt::InputDialog.getText self, "Sign Up",
        "Enter your password"
    # just cosmetic
        if two == nil
          two = 0
        end

    if(one == 0 || two == 0)
      Qt::MessageBox.about self, 'Trouble!', 'Didnt get your login and/or password. Try again.'
    else
      url = "http://138.68.173.185/cryptochat/product/adduser.php?login=#{one}&password=#{two}"
      RestClient.post(url, " ")
      Qt::MessageBox.about self, 'Nice one!', 'Thanks for signing up!'
    end
  end

app = Qt::Application.new ARGV
QtApp.new
app.exec
