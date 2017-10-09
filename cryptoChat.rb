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

    tester = Connection.new
    tester.testNew

    class QtApp < Qt::Widget

        def initialize
            super

            setWindowTitle "cryptoChat preAlpha-Omega v0.0.0.1"

            setToolTip "Test"

            resize 450, 600
            move 300, 300

            show
        end
    end

    app = Qt::Application.new ARGV
    QtApp.new
    app.exec

  end
