module Helpers
  def self.root
    File.expand_path('..', File.dirname(__FILE__))
  end

  def self.html_template_path(*args)
    File.join(root, 'html-template', *args)
  end

  def self.destination_path(*args)
    File.join(root, 'bin', *args)
  end
end
