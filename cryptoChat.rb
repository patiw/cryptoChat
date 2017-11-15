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

begin
  class Ui_CryptoChatMainWindow
      attr_reader :actionAddContact
      attr_reader :actionDeleteContact
      attr_reader :actionImportContacts
      attr_reader :actionExportContacts
      attr_reader :actionAbout
      attr_reader :actionQuit
      attr_reader :centralwidget
      attr_reader :verticalLayoutWidget
      attr_reader :vLayout
      attr_reader :textEdit
      attr_reader :verticalLayoutWidget_2
      attr_reader :vLayout2
      attr_reader :messageWindow
      attr_reader :horizontalLayoutWidget
      attr_reader :hLayout
      attr_reader :contactsView
      attr_reader :verticalScrollBar
      attr_reader :label
      attr_reader :sendText
      attr_reader :clearText
      attr_reader :menuBar
      attr_reader :menu_Menu
      attr_reader :menu_Contacts

      def setupUi(cryptoChatMainWindow)
        if cryptoChatMainWindow.objectName.nil?
            cryptoChatMainWindow.objectName = "cryptoChatMainWindow"
      end

      cryptoChatMainWindow.enabled = true
      cryptoChatMainWindow.resize(600, 560)
      cryptoChatMainWindow.maximumSize = Qt::Size.new(600, 560)
      @actionAddContact = Qt::Action.new(cryptoChatMainWindow)
      @actionAddContact.objectName = "actionAddContact"
      @actionDeleteContact = Qt::Action.new(cryptoChatMainWindow)
      @actionDeleteContact.objectName = "actionDeleteContact"
      @actionImportContacts = Qt::Action.new(cryptoChatMainWindow)
      @actionImportContacts.objectName = "actionImportContacts"
      @actionExportContacts = Qt::Action.new(cryptoChatMainWindow)
      @actionExportContacts.objectName = "actionExportContacts"
      @actionAbout = Qt::Action.new(cryptoChatMainWindow)
      @actionAbout.objectName = "actionAbout"
      @actionAbout.checkable = false
      @actionQuit = Qt::Action.new(cryptoChatMainWindow)
      @actionQuit.objectName = "actionQuit"
      @centralwidget = Qt::Widget.new(cryptoChatMainWindow)
      @centralwidget.objectName = "centralwidget"
      @verticalLayoutWidget = Qt::Widget.new(@centralwidget)
      @verticalLayoutWidget.objectName = "verticalLayoutWidget"
      @verticalLayoutWidget.geometry = Qt::Rect.new(10, 20, 401, 381)
      @vLayout = Qt::VBoxLayout.new(@verticalLayoutWidget)
      @vLayout.objectName = "vLayout"
      @vLayout.setContentsMargins(0, 0, 0, 0)
      @textEdit = Qt::TextEdit.new(@verticalLayoutWidget)
      @textEdit.objectName = "textEdit"
      @textEdit.enabled = false
      @textEdit.frameShape = Qt::Frame::Box
      @textEdit.frameShadow = Qt::Frame::Plain

      @vLayout.addWidget(@textEdit)

      @verticalLayoutWidget_2 = Qt::Widget.new(@centralwidget)
      @verticalLayoutWidget_2.objectName = "verticalLayoutWidget_2"
      @verticalLayoutWidget_2.geometry = Qt::Rect.new(10, 410, 401, 83)
      @vLayout2 = Qt::VBoxLayout.new(@verticalLayoutWidget_2)
      @vLayout2.objectName = "vLayout2"
      @vLayout2.setContentsMargins(0, 0, 0, 0)
      @messageWindow = Qt::TextEdit.new(@verticalLayoutWidget_2)
      @messageWindow.objectName = "messageWindow"

      @vLayout2.addWidget(@messageWindow)

      @horizontalLayoutWidget = Qt::Widget.new(@centralwidget)
      @horizontalLayoutWidget.objectName = "horizontalLayoutWidget"
      @horizontalLayoutWidget.geometry = Qt::Rect.new(420, 20, 170, 471)
      @hLayout = Qt::HBoxLayout.new(@horizontalLayoutWidget)
      @hLayout.objectName = "hLayout"
      @hLayout.setContentsMargins(0, 0, 0, 0)
      @contactsView = Qt::ListView.new(@horizontalLayoutWidget)
      @contactsView.objectName = "contactsView"

      @hLayout.addWidget(@contactsView)

      @verticalScrollBar = Qt::ScrollBar.new(@horizontalLayoutWidget)
      @verticalScrollBar.objectName = "verticalScrollBar"
      @verticalScrollBar.orientation = Qt::Vertical

      @hLayout.addWidget(@verticalScrollBar)

      @label = Qt::Label.new(@centralwidget)
      @label.objectName = "label"
      @label.geometry = Qt::Rect.new(420, 0, 56, 17)
      @sendText = Qt::PushButton.new(@centralwidget)
      @sendText.objectName = "sendText"
      @sendText.geometry = Qt::Rect.new(320, 500, 85, 27)
      @clearText = Qt::PushButton.new(@centralwidget)
      @clearText.objectName = "clearText"
      @clearText.geometry = Qt::Rect.new(230, 500, 85, 27)
      cryptoChatMainWindow.centralWidget = @centralwidget
      @menuBar = Qt::MenuBar.new(cryptoChatMainWindow)
      @menuBar.objectName = "menuBar"
      @menuBar.geometry = Qt::Rect.new(0, 0, 600, 27)
      @menu_Menu = Qt::Menu.new(@menuBar)
      @menu_Menu.objectName = "menu_Menu"
      @menu_Contacts = Qt::Menu.new(@menuBar)
      @menu_Contacts.objectName = "menu_Contacts"
      cryptoChatMainWindow.setMenuBar(@menuBar)

      @menuBar.addAction(@menu_Menu.menuAction())
      @menuBar.addAction(@menu_Contacts.menuAction())
      @menu_Menu.addAction(@actionAbout)
      @menu_Menu.addSeparator()
      @menu_Menu.addAction(@actionQuit)
      @menu_Contacts.addAction(@actionAddContact)
      @menu_Contacts.addAction(@actionDeleteContact)
      @menu_Contacts.addAction(@actionImportContacts)
      @menu_Contacts.addAction(@actionExportContacts)

      retranslateUi(cryptoChatMainWindow)

      Qt::Object.connect(@actionQuit, SIGNAL('triggered(bool)'), cryptoChatMainWindow, SLOT('close()'))
      Qt::Object.connect(@verticalScrollBar, SIGNAL('sliderMoved(int)'), @contactsView, SLOT('scrollToBottom()'))
      Qt::Object.connect(@clearText, SIGNAL('clicked()'), @messageWindow, SLOT('clear()'))

      Qt::MetaObject.connectSlotsByName(cryptoChatMainWindow)
      end # setupUi

      def setup_ui(cryptoChatMainWindow)
          setupUi(cryptoChatMainWindow)
      end

      def retranslateUi(cryptoChatMainWindow)
      cryptoChatMainWindow.windowTitle = Qt::Application.translate("cryptoChatMainWindow", "cryptoChat", nil, Qt::Application::UnicodeUTF8)
      @actionAddContact.text = Qt::Application.translate("cryptoChatMainWindow", "&Add new contact", nil, Qt::Application::UnicodeUTF8)
      @actionAddContact.shortcut = Qt::Application.translate("cryptoChatMainWindow", "Ctrl+A", nil, Qt::Application::UnicodeUTF8)
      @actionDeleteContact.text = Qt::Application.translate("cryptoChatMainWindow", "&Delete contact", nil, Qt::Application::UnicodeUTF8)
      @actionDeleteContact.shortcut = Qt::Application.translate("cryptoChatMainWindow", "Ctrl+D", nil, Qt::Application::UnicodeUTF8)
      @actionImportContacts.text = Qt::Application.translate("cryptoChatMainWindow", "&Import your contacts", nil, Qt::Application::UnicodeUTF8)
      @actionImportContacts.shortcut = Qt::Application.translate("cryptoChatMainWindow", "Ctrl+I", nil, Qt::Application::UnicodeUTF8)
      @actionExportContacts.text = Qt::Application.translate("cryptoChatMainWindow", "Export contacts to a file", nil, Qt::Application::UnicodeUTF8)
      @actionExportContacts.shortcut = Qt::Application.translate("cryptoChatMainWindow", "Ctrl+E", nil, Qt::Application::UnicodeUTF8)
      @actionAbout.text = Qt::Application.translate("cryptoChatMainWindow", "About", nil, Qt::Application::UnicodeUTF8)
      @actionAbout.shortcut = Qt::Application.translate("cryptoChatMainWindow", "Ctrl+H", nil, Qt::Application::UnicodeUTF8)
      @actionQuit.text = Qt::Application.translate("cryptoChatMainWindow", "&Quit", nil, Qt::Application::UnicodeUTF8)
      @actionQuit.shortcut = Qt::Application.translate("cryptoChatMainWindow", "Esc", nil, Qt::Application::UnicodeUTF8)
      @textEdit.html = Qt::Application.translate("cryptoChatMainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n" \
        "<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n" \
        "p, li { white-space: pre-wrap; }\n" \
        "</style></head><body style=\" font-family:'Noto Sans'; font-size:9pt; font-weight:400; font-style:normal;\">\n" \
        "<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"></p></body></html>", nil, Qt::Application::UnicodeUTF8)
      @messageWindow.html = Qt::Application.translate("cryptoChatMainWindow", "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0//EN\" \"http://www.w3.org/TR/REC-html40/strict.dtd\">\n" \
        "<html><head><meta name=\"qrichtext\" content=\"1\" /><style type=\"text/css\">\n" \
        "p, li { white-space: pre-wrap; }\n" \
        "</style></head><body style=\" font-family:'Noto Sans'; font-size:9pt; font-weight:400; font-style:normal;\">\n" \
        "<p style=\" margin-top:0px; margin-bottom:0px; margin-left:0px; margin-right:0px; -qt-block-indent:0; text-indent:0px;\"></p></body></html>", nil, Qt::Application::UnicodeUTF8)
      @label.text = Qt::Application.translate("cryptoChatMainWindow", "Contacts", nil, Qt::Application::UnicodeUTF8)
      @sendText.text = Qt::Application.translate("cryptoChatMainWindow", "Send", nil, Qt::Application::UnicodeUTF8)
      @clearText.text = Qt::Application.translate("cryptoChatMainWindow", "Clear", nil, Qt::Application::UnicodeUTF8)
      @menu_Menu.title = Qt::Application.translate("cryptoChatMainWindow", "&Menu", nil, Qt::Application::UnicodeUTF8)
      @menu_Contacts.title = Qt::Application.translate("cryptoChatMainWindow", "&Contacts", nil, Qt::Application::UnicodeUTF8)
      end # retranslateUi

      def retranslate_ui(cryptoChatMainWindow)
          retranslateUi(cryptoChatMainWindow)
      end

      def onchanged text
        @textEdit.setText text
      end
  end #class

  module Ui
      class CryptoChatMainWindow < Ui_CryptoChatMainWindow
      end
  end  # module Ui

    if $0 == __FILE__
        a = Qt::Application.new(ARGV)
        u = Ui_CryptoChatMainWindow.new
        w = Qt::MainWindow.new
        u.setupUi(w)
        w.show
        a.exec
    end
  end
end
