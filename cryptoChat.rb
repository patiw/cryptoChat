#Test of Qt-lib

#Requested gems and files
  require 'Qt4'
  require './connection'
  require './encryption'
  require './message'
  require './user'
  #in future classes gonna be pushed outside and linked here
  #awaiting for Patryk to decide on server choice

#"main"
  if __FILE__ == $0

    #key must be entered before the message process
    #suggestion: make the key generator and loading in other place
    a = XorshiftGen.new
    key = a.bytes(32).scan(/......../)
    key = key*" "

    x = File.read('text').chomp

    #loop do
        #puts "Write something: (type qqqqq to exit)"
    #    break if x == ""

        #x = $stdin.gets.chomp
    #    break if x == "qqqqq"
    #    puts x

    #    puts "Encrypted text: "
        #make class with initial varaibles of message and key
    #    message1 = Encryption.new(x, key)
        #x1 is the output of 3DES encrypt witch is an array
    #    x1 = message1.tripledes_encrypt
        #format the array to readable form
    #    puts x1.blocks(8).to_text

    #    puts "After decryption: "
        #make class with initial varaibles of message and key
    #    message2 = Encryption.new(x1, key)
        #x2 is the output of 3DES decrypt witch is an array
    #    x2 = message2.tripledes_decrypt
        #format the array to readable form
    #    puts x2#.recover_end_lines

    #    tmpArr = x.split("")
    #    tmpArr.shift(8)
    #    x = tmpArr.join

        ###TO DO: make x1 a string and encrypt the string, not an array
    #    sleep(5)
    #end

  class QtApp < Qt::MainWindow
    slots 'about()', 'sztuczka()'

    def initialize
      super

      setWindowTitle 'cryptoChat'

      setToolTip 'To jest okienko cryptoChatu'

      init_ui

      setFixedSize(560, 600)

      show
    end

    def init_ui
      hel = Qt::Action.new '&Help', self
      quit = Qt::Action.new '&Quit', self
      quit.setShortcut 'Esc'
      hel.setShortcut 'Ctrl+H'
      dod = Qt::Action.new '&Add new contact', self
      usu = Qt::Action.new '&Delete a contact', self
      imp = Qt::Action.new '&Import contacts from file', self
      exp = Qt::Action.new '&Export contacts to a file', self

      file = menuBar.addMenu '&Menu'
      file.addAction hel
      file.addAction quit

      kont = menuBar.addMenu '&Contacts'
      kont.addAction dod
      kont.addAction usu
      kont.addAction imp
      kont.addAction exp

      connect(quit, SIGNAL('triggered()'),
              Qt::Application.instance, SLOT('quit()'))

      vbox = Qt::VBoxLayout.new self
      vbox1 = Qt::VBoxLayout.new
      hbox1 = Qt::HBoxLayout.new
      hbox2 = Qt::HBoxLayout.new
      hbox3 = Qt::HBoxLayout.new

      # vbox1.addWidget about
      clearButt = Qt::PushButton.new "Clear", self
      @sendButt = Qt::PushButton.new "Send", self

      clearButt.geometry = Qt::Rect.new(230, 560, 70, 27)
      @sendButt.geometry = Qt::Rect.new(310, 560, 70, 27)

      connect(hel, SIGNAL('triggered()'),
              self, SLOT('about()'))

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
      connect(@sendButt, SIGNAL('clicked()'), self, SLOT('sztuczka()'))

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

    def sztuczka
      @plik = File.open('message.txt', 'a+')
      @plik.puts(@edit2.toPlainText())
      connect(@sendButt, SIGNAL('clicked()'), @edit2, SLOT('clear()'))
      stringText = File.read('message.txt')
      @edit.setText(stringText)
      @plik.close
    end

  end

  app = Qt::Application.new ARGV
  QtApp.new
  app.exec
end
