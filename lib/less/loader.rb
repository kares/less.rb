require 'pathname'
require 'commonjs'

module Less
  class Loader
    
    attr_reader :environment
    
    def initialize
      context_wrapper = Less::JavaScript.context_wrapper.instance
      @context = context_wrapper.unwrap
      @context['process'] = Process.new
      @context['console'] = Console.new
      path = Pathname(__FILE__).dirname.join('js', 'lib')
      @environment = CommonJS::Environment.new(@context, :path => path.to_s)
      @environment.native('path', Path)
      @environment.native('util', Util)
      @environment.native('fs', FS)
    end
    
    def require(module_id)
      @environment.require(module_id)
    end
    
    # stubbed JS modules required by less.js
    
    module Path
      def self.join(*components)
        File.join(*components)
      end

      def self.dirname(path)
        File.dirname(path)
      end

      def self.basename(path)
        File.basename(path)
      end
    end
    
    module Util
      def self.error(*errors)
        raise errors.join(' ')
      end
      
      def self.puts(*args)
        args.each { |arg| STDOUT.puts(arg) }
      end
    end

    module FS
      def self.statSync(path)
        File.stat(path)
      end

      def self.readFile(path, encoding, callback)
        callback.call(nil, File.read(path))
      end
    end

    class Process
      def exit(*args)
        warn("exit(#{args.first}) from #{caller}")
      end
    end

    class Console
      def log(*msgs)
        puts msgs.join(', ')
      end
    end
    
  end
end