#!/usr/bin/env ruby
# Requested gems and files
require 'Qt4'
require './encryption'
require './message'
require './key'
require 'thread'
require 'rest-client'
require 'json'
gem 'pg'
require 'pg'

# "main"
if $PROGRAM_NAME == __FILE__
  # Getting serverID from argument of starting program << login.rb system call
  $serverid = ARGV[0]
  $connectID = ''
  $last_message = ['', '', '1970-01-01 22:22:22']
  $old_rows_count = 0
  $new_rows_count = 0
  $my_name = `whoami`.chomp

  # QtApp patch for cryptoChat satisfy
  class QtApp < Qt::MainWindow
    attr_writer :on_time_up
    slots 'about()', 'sendText()', 'refreshText()', 'trunc()', 'clearHistory()',\
          'proba(int, int)', 'exportcontacts()', 'addcontact()', \
          'importcontacts()', 'deletecontact()', 'importmessages()', 'showserverid()', \
          'gen_new_key()', 'set_conv_key()', 'show_conv_key()'

    def initialize
      super

      puts 'Version of libpg: ' + PG.library_version.to_s
      puts $my_name
      def with_db
        db = PG.connect(
          dbname: 'cryptochat',
          user: "#{$my_name}"
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
      @timer.start(1000)

      setWindowTitle 'cryptoChat'

      init_ui

      setFixedSize(560, 600)
      setStyleSheet("background-color:
                     qlineargradient(x1: 0, y1:1.2, x2:0, y2:0,
                     stop:0 #00CDAA, stop:1 #004E40);")
      show
    end

    def init_ui
      users = 'https://api.iwaniuk.xyz/cryptochat/product/users.php'
      response = RestClient.get(users)
      @parsed_users = JSON.parse(response)

      hel = Qt::Action.new '&Help', self
      clr = Qt::Action.new '&Clear chat window', self
      quit = Qt::Action.new '&Quit', self
      quit.setShortcut 'Esc'
      hel.setShortcut 'Ctrl+H'
      clr.setShortcut 'Ctrl+Delete'
      serID = Qt::Action.new '&Show me my serverID', self
      dod = Qt::Action.new '&Add new contact', self
      usu = Qt::Action.new '&Delete a contact', self
      imp = Qt::Action.new '&Import contacts from file', self
      exp = Qt::Action.new '&Export contacts to a file', self
      generate_key = Qt::Action.new '&Generate new random key', self
      set_new_key = Qt::Action.new '&Set new key for conversation', self
      show_the_key = Qt::Action.new '&Show actual key', self

      messageBoxStyle = "QDialog {
                          background-color: #009A80;
                         }
                         QLabel {
                          font-size: 14px;
                          background-color: transparent;
                         }
                         QPushButton {
                          background-color: #009A80;
                          border-style: solid;
                          border-width:1px;
                          border-radius:10px;
                          border-color: #D9FFF8;
                          max-width:100px;
                          max-height:50px;
                          min-width:60px;
                          min-height:30px;
                        }
                        QPushButton:pressed {
                          background-color: #004E40;
                          color: yellow;
                        }"

      # screen_prop = Qt::Rect.new
      screen_prop = Qt::Application.desktop.availableGeometry
      # screen_center = Qt::Point.new
      screen_center = screen_prop.center
      screen_x = screen_center.x - screen_prop.width * 0.25
      screen_y = screen_center.y - screen_prop.height * 0.25

      @messageBox = Qt::Dialog.new(self)
      @messageBox.adjustSize
      @messageBox.move(screen_x, screen_y)
      @messageBox.setStyleSheet(messageBoxStyle)

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

      sub_menu_style = "QMenu {
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
                               }"

      @menuFile = Qt::Menu.new(@menuBar)
      @menuFile.setObjectName('menuFile')
      @menuFile.setTitle('File')
      @menuFile.addAction(hel)
      @menuFile.addAction(clr)
      @menuFile.addAction(quit)
      @menuFile.setStyleSheet(sub_menu_style)

      @menuKont = Qt::Menu.new(@menuBar)
      @menuKont.setObjectName('menuKont')
      @menuKont.setTitle('Account')
      @menuKont.addAction serID
      @menuKont.addAction dod
      @menuKont.addAction usu
      @menuKont.addAction imp
      @menuKont.addAction exp
      @menuKont.setStyleSheet(sub_menu_style)

      @menuKey = Qt::Menu.new(@menuBar)
      @menuKey.setObjectName('menuKey')
      @menuKey.setTitle('Keys')
      @menuKey.addAction show_the_key
      @menuKey.addAction set_new_key
      @menuKey.addAction generate_key
      @menuKey.setStyleSheet(sub_menu_style)

      @menuBar.addAction(@menuFile.menuAction)
      @menuBar.addAction(@menuKont.menuAction)
      @menuBar.addAction(@menuKey.menuAction)

      connect(hel, SIGNAL('triggered()'), self, SLOT('about()'))
      connect(clr, SIGNAL('triggered()'), self, SLOT('clearHistory()'))
      connect(quit, SIGNAL('triggered()'),
              Qt::Application.instance, SLOT('quit()'))
      connect(exp, SIGNAL('triggered()'), self, SLOT('exportcontacts()'))
      connect(dod, SIGNAL('triggered()'), self, SLOT('addcontact()'))
      connect(imp, SIGNAL('triggered()'), self, SLOT('importcontacts()'))
      connect(usu, SIGNAL('triggered()'), self, SLOT('deletecontact()'))
      connect(serID, SIGNAL('triggered()'), self, SLOT('showserverid()'))
      connect(generate_key, SIGNAL('triggered()'), self, SLOT('gen_new_key()'))
      connect(set_new_key, SIGNAL('triggered()'), self, SLOT('set_conv_key()'))
      connect(show_the_key, SIGNAL('triggered()'), self, SLOT('show_conv_key()'))

      # vbox  = Qt::VBoxLayout.new self
      vbox1 = Qt::VBoxLayout.new
      hbox1 = Qt::HBoxLayout.new
      hbox2 = Qt::HBoxLayout.new
      # hbox3 = Qt::HBoxLayout.new

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

      # vbox1.addWidget about
      clearButt = Qt::PushButton.new "Clear", self
      clearButt.setFont Qt::Font.new "Impact", 12
      clearButt.setStyleSheet(buttonStyle)

      @sendButt = Qt::PushButton.new "Send", self
      @sendButt.setFont Qt::Font.new "Impact", 12
      @sendButt.setStyleSheet(buttonStyle)

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
      @edit.setEnabled false

      # hbox1.addWidget @edit
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

      vbox1.addWidget label
      label.resize 84, 50
      label.move 390, 10

      @table = Qt::TableWidget.new self
      @table2 = Qt::TableWidget.new self

      db = PG.connect(
        dbname: 'cryptochat',
        user: "#{$my_name}",
      )
      kont = db.exec("SELECT * FROM chatcontacts")
      # wiad = db.exec("SELECT * FROM chatmessages")

      # cmd_tuples returns number of rows affected by sql query
      x = kont.cmdtuples

      @table2.resize(360, 400)
      @table2.move(20, 40)
      #@table2.setRowCount(@y)
      @table2.setColumnCount(2)
      @table2.verticalHeader.hide
      @table2.horizontalHeader.setDefaultSectionSize(170)
      @table2.horizontalHeader.setResizeMode(Qt::HeaderView::Fixed)
      @table2.horizontalHeader.hide
      @table2.setEditTriggers(Qt::AbstractItemView::NoEditTriggers)
      @table2.setWordWrap(true)
      @table2.setShowGrid(false)
      @table2.setSelectionMode(Qt::AbstractItemView::NoSelection)

      @table.resize(150, 510)
      @table.move(390, 40)
      @table.setRowCount(x)
      @table.setColumnCount(1)
      @table.horizontalHeader.setDefaultSectionSize(150)
      @table.verticalHeader.hide
      @table.horizontalHeader.hide
      @table.setEditTriggers(Qt::AbstractItemView::NoEditTriggers)

      # magic trick to iteration over each row in table
      db.close

      refreshContacts

      vbox1.addWidget @table

      hbox1.addWidget @table2

      @table.setStyleSheet("background-color: #D9FFF8;
                                border-style: none;
                                border-width:0px;
                                border-color: #D9FFF8;")

      @table2.setStyleSheet("background-color: #D9FFF8;
                                border-style: none;
                                border-width:0px;
                                border-color: #D9FFF8;")

      connect(@table, SIGNAL('cellDoubleClicked(int, int)'), self, SLOT('proba(int, int)'))
    end

    def about
      Qt::MessageBox.about @messageBox, 'About', 'Aby wybrać kontakt, kliknij dwukrotnie na wybranym kontakcie
      Aby dodać kontakt, wybierz opcję Add new contact i podążaj za wskazówkami
      W razie gwałtownego spowolnienia programu, użyj opcji Clear chat window
      W razie problemów, skontaktuj się z twóracami na https://github.com/patiw/cryptoChat'
    end

    # Clears table with messages
    def clearHistory
      Message::deleteContent(@table2)
    end

    # Refresh text(messages) in table widget
    def refreshText
      importmessages
      Message::refreshTextBox(@table2)
    end

    # Refresh contacts in table "contact"
    def refreshContacts
      db = PG.connect(
        dbname: 'cryptochat',
        user: "#{$my_name}",
      )
      kont = db.exec("SELECT * FROM chatcontacts")

      i = -1

        kont.each do |row|
          @table.setItem(i+=1 , 0, Qt::TableWidgetItem.new("#{row['name']}"))
        end
      db.close
    end

    def sendText
      if $connectID == ''
        Qt::MessageBox.about @messageBox, 'Error', 'You dunno de wae'
      else
        Message::sendTextBox(@edit2)
        @edit2.clear
      end
    end

    # Exports contacts to "contacts.txt" file
    def exportcontacts
      db = PG.connect(
        dbname: 'cryptochat',
        user: "#{$my_name}",
      )
        kont = db.exec("SELECT * FROM chatcontacts")

        kontakty = File.open('contacts.txt', 'w')

        kont.each do |row|
          kontakty.write("#{row['name']} #{row['serverid']}\n")
        end
      db.close
      kontakty.close
      Qt::MessageBox.about @messageBox, 'Export!', "Contacts exported to contacts.txt!"
    end

    # Imports contacts from chosen file
    def importcontacts
      name = Qt::FileDialog::getOpenFileName self, 'Choose a file', '/home'

      unless name.nil?
        nazwa = Qt::FileInfo.new(name)
        plik = nazwa.fileName

        kontakty = File.open(plik, 'r')

        db = PG.connect(
          dbname: 'cryptochat',
          user: "#{$my_name}",
        )

        while (line = kontakty.gets)
          cos = line.split
          db.exec("INSERT INTO chatcontacts(name, serverid) VALUES($1, $2)", [cos[0], cos[1]])
        end
        kontakty.close
        db.close
        Qt::MessageBox.about @messageBox, 'Import!', "Contacts imported from #{plik}!"
      end
    end

    # Add connect to tabel "contacts"
    def addcontact
      users = 'https://api.iwaniuk.xyz/cryptochat/product/users.php'
      response = RestClient.get(users)
      @parsed_users = JSON.parse(response)

      counter = 0
      x = @parsed_users["records"].length
      login = Qt::InputDialog.getText @messageBox, "Adding a Contact",
          "Enter the name: "
      serverid = Qt::InputDialog.getText @messageBox, "Adding a Contact",
          "Enter the serverID: "
      key_input = Qt::InputDialog.getText @messageBox, "Adding a Contact",
          "Enter the key: "

        (0...x).each do |i|
            if(@parsed_users["records"][i]["serverID"] == serverid)
              counter = 1
            end
        end
        if counter == 1
        db = PG.connect(
          dbname: 'cryptochat',
          user: "#{$my_name}",
        )
          db.exec("INSERT INTO chatcontacts(name, serverid, key) VALUES ($1, $2, $3)", \
                  [login, serverid, key_input])
        db.close
        Qt::MessageBox.about @messageBox, 'Added!', "Added contact #{login}!"
        @table.insertRow(@table.rowCount)
        refreshContacts
        else
          Qt::MessageBox.about @messageBox, 'Oops!', "We have not such contact in our database!"
        end
    end

    def deletecontact
      counter = 0
      login = Qt::InputDialog.getText @messageBox, "Delete a Contact",
          "Enter a name: "
      db = PG.connect(
        dbname: 'cryptochat',
        user: "#{$my_name}",
      )
      kont = db.exec("SELECT * FROM chatcontacts")
      x = kont.cmdtuples

      kont.each do |row|
        if("#{row['name']}" == login)
          counter = 1
        end
      end
        if counter == 1
          db.exec("DELETE FROM chatcontacts WHERE name=$1", [login])
          Qt::MessageBox.about @messageBox, 'Deleted!', "Deleted contact #{login}!"
          @table.removeRow(x-1)
          refreshContacts
        else
          Qt::MessageBox.about @messageBox, 'Oops!', "We have not such contact in our database or you clicked cancel!"
        end
      db.close
    end

    # to musi byc user1, user2, userID musi byc wysylany
    def importmessages
      urliu = "https://api.iwaniuk.xyz/cryptochat/product/messages.php?user1=#{$serverid}&user2=#{$connectID}"
      responsea = RestClient.get(urliu)
      mestab = JSON.parse(responsea)

      if mestab['messages'] != nil
        x = mestab['messages'].length
      else
        x = 0
      end

      db = PG.connect(
        dbname: 'cryptochat',
        user: "#{$my_name}",
      )

      if $connectID != $old_connect_ID
        clearHistory
        $old_connect_ID = $connectID
        $last_message = ['', '', '1970-01-01 22:22:22']
        db.exec("DELETE FROM chatmessages")
        db.exec("ALTER SEQUENCE chatMessages_id_seq RESTART WITH 1")
        (0...x).each do |i|
          db.exec("INSERT INTO chatmessages(sender, receiver, text, date) VALUES($1, $2, $3, $4)", [mestab['messages'][i]['sender'], mestab['messages'][i]['receiver'], mestab['messages'][i]['text'], mestab['messages'][i]['date']])
        end
      else
        max_tab = db.exec("SELECT max(id) from chatmessages")
        max_id = (max_tab[0]['max']).to_i
        (max_id...x).each do |i|
          db.exec("INSERT INTO chatmessages(sender, receiver, text, date) VALUES($1, $2, $3, $4)", [mestab['messages'][i]['sender'], mestab['messages'][i]['receiver'], mestab['messages'][i]['text'], mestab['messages'][i]['date']])
        end
      end
      db.close
    end

    def showserverid
      Qt::MessageBox.about @messageBox, 'My ServerID', "ServerID: #{$serverid}"
    end

    def gen_new_key
      random_key = GenerateKey::genkey
      Qt::MessageBox.about @messageBox, 'Generation', "Random key: \n#{random_key}"
    end

    def show_conv_key
      Qt::MessageBox.about @messageBox, 'My key', "Key: \n#{$conv_key}"
    end

    def set_conv_key
      new_key_input = Qt::InputDialog.getText @messageBox, "Setting new key",
                      "Enter new key: "

      unless new_key_input.nil?
        new_key_input = new_key_input.chomp
        if new_key_input.length == 143
          db = PG.connect(
            dbname: 'cryptochat',
            user: "#{$my_name}",
          )
          db.exec("UPDATE chatcontacts SET key = '#{new_key_input}' WHERE serverid = '#{$connectID}'")

          db.close
          Qt::MessageBox.about @messageBox, 'Setting new key', "Done!"
          $conv_key = new_key_input
        else
          puts new_key_input.length
          Qt::MessageBox.about @messageBox, 'Oops!', "You entered the key in a wrong way!\nCheck the length of key or maybe you missed some spaces."
        end
      end
    end

    def proba(x, y)
      db = PG.connect(
        dbname: 'cryptochat',
        user: "#{$my_name}",
      )
      $old_connect_ID = $connectID
      connectIDserver = db.exec("SELECT serverid, key FROM chatcontacts WHERE name='#{@table.item(x, y).text()}'")
      $connectID = connectIDserver[0]['serverid']
      $conv_key = connectIDserver[0]['key']
      db.close
      Qt::MessageBox.about @messageBox, 'cryptoChat', "Connected to #{@table.item(x, y).text()}"
    end
  end

    app = Qt::Application.new ARGV
    QtApp.new

    app.exec
end
