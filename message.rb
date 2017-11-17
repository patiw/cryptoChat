#Message module
module Message
  def refreshTextBox(box)
    stringText = File.read('message.txt')
    box.setText(stringText)
  end

  def sendTextBox(box, adres)
    file = File.open(adres, 'a+')
    file.puts(box.toPlainText())
    box.clear
    file.close
  end

  module_function :refreshTextBox, :sendTextBox
end
