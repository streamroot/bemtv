namespace :assets do
  desc "Creates folders on destination."
  task :create_dirs do
    FileUtils.mkdir_p(Helpers.destination_path)
  end

  desc "Copies templates to destination."
  task :copy => [:create_dirs] do
    Dir[Helpers.html_template_path('**', '*')].sort.each do |file|
      destination = file.gsub(Helpers.html_template_path, Helpers.destination_path)
      if File.directory?(file)
        FileUtils.mkdir_p(destination)
      else
        FileUtils.cp_r(file, destination)
      end
    end
    FileUtils.mv Helpers.destination_path('index.template.html'), Helpers.destination_path('StrobeMediaPlayback.html')
  end

  task :rename_debug_swf => :copy do
    FileUtils.mv Helpers.destination_path('StrobeMediaPlayback-debug.swf'), Helpers.destination_path('StrobeMediaPlayback.swf')
  end
end
