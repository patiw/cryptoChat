# Test of Qt-lib

# Requested gems and files
  require 'Qt4'
  require './connection'
  require './encryption'
  require './message'
  require './user'
  require './key'
  require 'thread'
  # in future classes gonna be pushed outside and linked here
  # awaiting for Patryk to decide on server choice

# "main"
if $PROGRAM_NAME == __FILE__

    # key must be entered before the message process
    # suggestion: make the key generator and loading in other place

    #x = File.read('text').chomp

    #loop do
        #puts "Write something: (type qqqqq to exit)"
        #break if x == ""

        #x = $stdin.gets.chomp
       #puts x

       #puts "Encrypted text: "
        # make class with initial varaibles of message and key
       #message1 = Encryption.new(x, key)
        # x1 is the output of 3DES encrypt witch is an array
       #x1 = message1.tripledes_encrypt
        # format the array to readable form
       #puts x1.blocks(8).to_text

       #puts "After decryption: "
        # make class with initial varaibles of message and key
       #message2 = Encryption.new(x1, key)
        # x2 is the output of 3DES decrypt witch is an array
       #x2 = message2.tripledes_decrypt
        # format the array to readable form
       #puts x2 # .recover_end_lines

       #tmpArr = x.split("")
       #tmpArr.shift(8)
       #x = tmpArr.join

        ### TO DO: make x1 a string and encrypt the string, not an array
       #sleep(5)
    #end

  # QtApp patch for cryptoChat satisfy
  class QtApp < Qt::MainWindow
    attr_writer :on_time_up
    slots 'about()', 'sendText()', 'refreshText()', 'trunc()'

    def initialize
      super

      # Use Timer for "multi-threading"
      # Main idea is we call some function in main app.exec thread
      # on time specified after timer expires. To refresh text we
      # only function called later and make sure it's slot type.
      # Timer needs to be instance variable since app is an instance.
      # No need for threading now. It's quite difficult to combine
      # QtRubyBindings with Ruby Threading. In futute we can make
      # more and more timers executing different functions.
      @timer = Qt::Timer.new(self)
      connect(@timer, SIGNAL(:timeout), self, SLOT('refreshText()'))
      @timer.start(10)

      setWindowTitle 'cryptoChat'

      setToolTip 'To jest okienko cryptoChatu'

      init_ui

      setFixedSize(560, 600)

      show
    end

    def init_ui
      hel = Qt::Action.new '&Help', self
      clr = Qt::Action.new '&Delete current chat history', self
      quit = Qt::Action.new '&Quit', self
      quit.setShortcut 'Esc'
      hel.setShortcut 'Ctrl+H'
      dod = Qt::Action.new '&Add new contact', self
      usu = Qt::Action.new '&Delete a contact', self
      imp = Qt::Action.new '&Import contacts from file', self
      exp = Qt::Action.new '&Export contacts to a file', self

      file = menuBar.addMenu '&Menu'
      file.addAction hel
      file.addAction clr
      file.addAction quit

      kont = menuBar.addMenu '&Contacts'
      kont.addAction dod
      kont.addAction usu
      kont.addAction imp
      kont.addAction exp


      connect(hel, SIGNAL('triggered()'),
              self, SLOT('about()'))

      connect(clr, SIGNAL('triggered()'),
              self, SLOT('trunc()'))

      connect(quit, SIGNAL('triggered()'),
              Qt::Application.instance, SLOT('quit()'))

      # vbox  = Qt::VBoxLayout.new self
      vbox1 = Qt::VBoxLayout.new
      hbox1 = Qt::HBoxLayout.new
      hbox2 = Qt::HBoxLayout.new
      # hbox3 = Qt::HBoxLayout.new

      # vbox1.addWidget about
      clearButt = Qt::PushButton.new "Clear", self
      @sendButt = Qt::PushButton.new "Send", self

      clearButt.geometry = Qt::Rect.new(230, 560, 70, 27)
      @sendButt.geometry = Qt::Rect.new(310, 560, 70, 27)

      clearButt.setShortcut('Ctrl+Backspace')
      @sendButt.setShortcut('Ctrl+Return')

      label = Qt::Label.new 'Kontakty', self

      @edit = Qt::TextEdit.new self
      @edit.setEnabled true

      hbox1.addWidget @edit
      @edit.resize 360, 400
      @edit.move 20, 40

      @edit2 = Qt::TextEdit.new self
      @edit2.setEnabled true

      hbox2.addWidget @edit2
      @edit2.resize 360, 100
      @edit2.move 20, 450

      connect(clearButt, SIGNAL('clicked()'), @edit2, SLOT('clear()'))
      connect(@sendButt, SIGNAL('clicked()'), self, SLOT('sendText()'))

      contacts = Qt::ListView.new self

      vbox1.addWidget label
      label.move 390, 15

      vbox1.addWidget contacts
      contacts.resize 150, 510
      contacts.move 390, 40
    end

    def about
      Qt::MessageBox.about self, 'About', 'Zobaczymy'
    end

    def trunc
      Message::deleteContent('message.txt')
    end

    def refreshText
      Message::refreshTextBox(@edit)
    end

    def sendText
      Message::sendTextBox(@edit2,'message.txt')
    end
  end

    app = Qt::Application.new ARGV
    QtApp.new

    app.exec
end
