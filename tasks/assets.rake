namespace :assets do
  def asset_config
    @asset_config ||= begin
      require 'yaml'
      YAML.load Padrino.root('config/assets.yml')
    end
  end

  def invoke_or_reboot_rake_task(task)
    Rake::Task[task].invoke
  end

  task :test_node do
    begin
      `node -v`
    rescue Errno::ENOENT
      STDERR.puts <<-EOM
        Unable to find 'node' on the current path.
      EOM
      exit 1
    end
  end

  namespace :precompile do
    task :all => ["assets:precompile:rjs",
                  "assets:precompile:css"]

    task :external => ["assets:test_node"] do
      Rake::Task["assets:precompile:all"].invoke
    end

    task :rjs => :environment do
      res = %x[cd #{Padrino.root('public/js')} && node #{Padrino.root('build/r.js')} -o mainConfigFile=config.js baseUrl=. name=vendor/almond.js include=main out=../build/app.js optimize=uglify2]
      raise RuntimeError, "JS compilation with r.js failed. \n #{res}" unless $?.success?
    end

    task :css do
      %w(main.css main.ie.css).each do |css|
        tmp_file = Padrino.root('tmp', css)
        in_file = Padrino.root('public/css', css)
        out_file = Padrino.root('public/build', css)

        puts "node #{Padrino.root('build/r.js')} -o cssIn=#{in_file} out=#{tmp_file} cssPrefix=/css cssKeepLicense=true preserveLicenseComments=true"
        res = %x[cd #{Padrino.root} && node #{Padrino.root('build/r.js')} -o cssIn=#{in_file} out=#{tmp_file} cssPrefix=/css cssKeepLicense=true preserveLicenseComments=true]
        puts res
        raise RuntimeError, "r.js CSS compilation failed" unless $?.success?

        puts "node #{Padrino.root('build/clean-css.js')} --skip-import --skip-rebase --s0 -o #{out_file} #{tmp_file}"
        res = %x[node #{Padrino.root('build/clean-css.js')} --skip-import --skip-rebase --s0 -o #{out_file} #{tmp_file}]
        puts res
        raise RuntimeError, "clean-css compilation failed." unless $?.success?
        File.delete tmp_file
      end
    end

    task :less do
      #less = File.open('public/less/main.less', 'r').read
      #parser = Less::Parser.new :paths => ['public/less/']
      #tree = parser.parse less
      #css = tree.to_css
      #Dir.mkdir 'public/css/'
      #File.open('public/css/styles.css', 'w') {|f| f.write(css) }
    end
  end

  desc "Precompile JS and LESS assets"
  task :precompile do
    invoke_or_reboot_rake_task "assets:precompile:all"
  end
end
task "assets:precompile" => ["assets:precompile:external"]