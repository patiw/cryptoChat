# Test of Qt-lib

# Requested gems and files
  require 'Qt4'
  require './connection'
  require './encryption'
  require './message'
  require './user'
  require './key'
  require 'thread'
  gem 'pg'
  require 'pg'
  # in future classes gonna be pushed outside and linked here
  # awaiting for Patryk to decide on server choice

# "main"
if $PROGRAM_NAME == __FILE__

  # QtApp patch for cryptoChat satisfy
  class QtApp < Qt::MainWindow
    attr_writer :on_time_up
    slots 'about()', 'sendText()', 'refreshText()', 'trunc()', 'clearHistory()'

    def initialize
      super

      puts 'Version of libpg: ' + PG.library_version.to_s
      def with_db
        db = PG.connect(
          dbname: 'dat_boi',
          user: 'dat_boi',
          password: 'cryptochat'
        )
        begin
           yield db
        ensure
           db.close
        end
      end

      sql = File.open('skrypt.sql', 'rb') { |file| file.read }
      with_db do |db|
        begin
          db.exec(sql)
        rescue PG::Error
           #####
        end
      end

      # Use Timer for "multi-threading"
      # Zastąpić to potem wątkami!!!
      # Main idea is we call some function in main app.exec thread
      # on time specified after timer expires. To refresh text we
      # only function called later and make sure it's slot type.
      # Timer needs to be instance variable since app is an instance.
      # No need for threading now. It's quite difficult to combine
      # QtRubyBindings with Ruby Threading. In futute we can make
      # more and more timers executing different functions.
      @timer = Qt::Timer.new(self)
      connect(@timer, SIGNAL(:timeout), self, SLOT('refreshText()'))
      @timer.start(500)

      setWindowTitle 'cryptoChat'

      setToolTip 'cryptoChat'

      init_ui

      setFixedSize(560, 600)
      setStyleSheet("background-color:
                     qlineargradient(x1: 0, y1:1.2, x2:0, y2:0,
                     stop:0 #00CDAA, stop:1 #004E40);");
      show
    end

    def init_ui
      hel = Qt::Action.new '&Help', self
      clr = Qt::Action.new '&Delete current chat history', self
      quit = Qt::Action.new '&Quit', self
      quit.setShortcut 'Esc'
      hel.setShortcut 'Ctrl+H'
      clr.setShortcut 'Ctrl+Delete'
      dod = Qt::Action.new '&Add new contact', self
      usu = Qt::Action.new '&Delete a contact', self
      imp = Qt::Action.new '&Import contacts from file', self
      exp = Qt::Action.new '&Export contacts to a file', self

      @menuBar = Qt::MenuBar.new(self)
      @menuBar.setGeometry(Qt::Rect.new(0, 0, 800, 60))
      @menuBar.setStyleSheet("QMenuBar {
                                background-color: transparent;
                                color: #D9FFF8;
                              }
                              QMenuBar:item {
                                background-color: transparent;
                              }
                              QMenuBar:item:selected {
                                color: #FFF200;
                              }
                              QMenuBar:item:pressed {
                                color: #BFB600;
                                border-style: solid;
                                border-width:1px;
                                border-top-color: #D9FFF8;
                                border-left-color: #D9FFF8;
                                border-right-color: #D9FFF8;
                                border-bottom-color: transparent;
                              }")

      @menuFile = Qt::Menu.new(@menuBar)
      @menuFile.setObjectName('menuFile')
      @menuFile.setTitle('File')
      @menuFile.addAction(hel)
      @menuFile.addAction(clr)
      @menuFile.addAction(quit)
      @menuFile.setStyleSheet("QMenu {
                                border-style: solid;
                                border-width:1px;
                                border-color: #D9FFF8;
                               color: #D9FFF8;
                               background-color:
                               qlineargradient(x1: 0, y1:2, x2:0, y2:0,
                               stop:0 lightgray, stop:1 #004E40);
                               }
                               QMenu:item:selected {
                                 color: #FFF200;
                                 background-color: #004E40;
                                 padding: 0px 25px 2px 20px;
                                 border: 1px solid transparent;
                               }
                               QMenu:item:pressed {
                                 color: #BFB600;
                               }");

      @menuKont = Qt::Menu.new(@menuBar)
      @menuKont.setObjectName('menuKont')
      @menuKont.setTitle('Account')
      @menuKont.addAction dod
      @menuKont.addAction usu
      @menuKont.addAction imp
      @menuKont.addAction exp
      @menuKont.setStyleSheet("QMenu {
                                border-style: solid;
                                border-width:1px;
                                border-color: #D9FFF8;
                               color: #D9FFF8;
                               background-color:
                               qlineargradient(x1: 0, y1:2, x2:0, y2:0,
                               stop:0 lightgray, stop:1 #004E40);
                               }
                               QMenu:item:selected {
                                 color: #FFF200;
                                 background-color: #004E40;
                                 padding: 0px 25px 2px 20px;
                                 border: 1px solid transparent;
                               }
                               QMenu:item:pressed {
                                 color: #BFB600;
                               }");

      @menuBar.addAction(@menuFile.menuAction())
      @menuBar.addAction(@menuKont.menuAction())

      connect(hel, SIGNAL('triggered()'), self, SLOT('about()'))
      connect(clr, SIGNAL('triggered()'), self, SLOT('clearHistory()'))
      connect(quit, SIGNAL('triggered()'),
              Qt::Application.instance, SLOT('quit()'))

      # vbox  = Qt::VBoxLayout.new self
      vbox1 = Qt::VBoxLayout.new
      hbox1 = Qt::HBoxLayout.new
      hbox2 = Qt::HBoxLayout.new
      # hbox3 = Qt::HBoxLayout.new

      # vbox1.addWidget about
      clearButt = Qt::PushButton.new "Clear", self
      clearButt.setFont Qt::Font.new "Impact", 12
      clearButt.setStyleSheet("QPushButton {
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
                               }")

      @sendButt = Qt::PushButton.new "Send", self
      @sendButt.setFont Qt::Font.new "Impact", 12
      @sendButt.setStyleSheet("QPushButton {
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
                               }")

      # @sendButt.pressed::setStyleSheet("color: yellow;")

      clearButt.geometry = Qt::Rect.new(230, 560, 70, 27)
      @sendButt.geometry = Qt::Rect.new(310, 560, 70, 27)

      clearButt.setShortcut('Ctrl+Backspace')
      @sendButt.setShortcut('Ctrl+Return')

      label = Qt::Label.new 'Contacts', self
      label.setFont Qt::Font.new "Impact", 12
      label.setStyleSheet("background-color: #009A80;
                               border-style: solid;
                               border-width:2px;
                               border-radius:5px;
                               border-color: #D9FFF8;
                               max-width:100px;
                               max-height:30px;
                               min-width:30px;
                               min-height:30px;")

      @edit = Qt::TextEdit.new self
      @edit.setEnabled true

      hbox1.addWidget @edit
      @edit.resize 360, 400
      @edit.move 20, 40
      @edit.setFont Qt::Font.new "Impact", 11
      @edit.setStyleSheet("background-color: white")

      @edit2 = Qt::TextEdit.new self
      @edit2.setEnabled true

      hbox2.addWidget @edit2
      @edit2.resize 360, 100
      @edit2.move 20, 450
      @edit2.setFont Qt::Font.new "Impact", 11
      @edit2.setStyleSheet("background-color: white")

      connect(clearButt, SIGNAL('clicked()'), @edit2, SLOT('clear()'))
      connect(@sendButt, SIGNAL('clicked()'), self, SLOT('sendText()'))

      @contacts = Qt::ListView.new self

      vbox1.addWidget label
      label.resize 84, 50
      label.move 390, 10

      vbox1.addWidget @contacts
      @contacts.resize 150, 510
      @contacts.move 390, 40
      @contacts.setStyleSheet("background-color: #D9FFF8;
                                border-style: solid;
                                border-width:3px;
                                border-color: #D9FFF8;")
    end

    def about
      Qt::MessageBox.about self, 'About', 'Zobaczymy'
    end

    def clearHistory
      Message::deleteContent(@edit, 'message')
    end

    def refreshText
      Message::refreshTextBox(@edit)
    end

    def sendText
      Message::sendTextBox(@edit2,'message')
    end
  end
    ####################################################
    #TO DELETE LATER
    Message::checkIfFileExist
    ####################################################
    app = Qt::Application.new ARGV
    QtApp.new

    app.exec
end
