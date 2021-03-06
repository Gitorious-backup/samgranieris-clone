# The Strainer class (and the associated script/gitorious) was inspired by
# the approach gitosis (http://eagain.net/gitweb/?p=gitosis.git) takes, 
# frankly the meat of it is a straight up port/fork of the core functionality, 
# including logic and general approach.
# Gitosis is of this writing licensed under the GPLv2 and is copyright (c) Tommi Virtanen
# and can be found at http://eagain.net/gitweb/?p=gitosis.git
# Gitorious::SSH::Strainer is licensed under the same license.

module Gitorious
  module SSH
    class BadCommandError < StandardError
    end
  
    class Strainer
    
      COMMANDS_READONLY = [ 'git-upload-pack' ]
      COMMANDS_WRITE    = [ 'git-receive-pack' ]
      ALLOW_RE = /^'([a-z0-9][a-z0-9@._\-]*(\/[a-z0-9][a-z0-9@\._\-]*)*\.git)'$/i.freeze
    
      def initialize(command)
        @command = command
        @verb = nil
        @argument = nil
        @path = nil
      end
      attr_reader :path, :verb, :command
    
      def full_path
        File.join(GitoriousConfig["repository_base_path"], path)
      end
    
      def parse!
        if @command.include?("\n")
          raise BadCommandError
        end
      
        @verb, @argument = @command.split(" ")
        if @argument.nil? || @argument.is_a?(Array)
          # all known commands take one argument; improve if/when needed
          raise BadCommandError
        end
      
        if !(COMMANDS_WRITE.include?(@verb)) && !(COMMANDS_READONLY.include?(@verb))
          raise BadCommandError
        end
      
        if ALLOW_RE =~ @argument
          @path = $1
          raise BadCommandError unless @path
        else
          raise BadCommandError
        end
      
        self
      end
    end
  end
end
