require 'guard'
require 'guard/plugin'
require "guard/compat/plugin"
require 'rubygems'

module Guard
  class Passenger < Plugin

    autoload :Runner, 'guard/passenger/runner'
    autoload :Pinger, 'guard/passenger/pinger'

    attr_reader :cli_start, :cli_stop, :ping, :notification, :sudo, :running

    def standalone?
      @standalone
    end

    def running?
      @running
    end

    # =================
    # = Guard methods =
    # =================

    def initialize(options = {})
      super

      @standalone   = options[:standalone].nil? ? true : options[:standalone]
      @cli_start    = init_cli(options)
      @cli_stop     = cli_stop
      @notification = options[:notification].nil? ? true : options[:notification]

      @ping = options[:ping].eql?(true) ? '/' : options[:ping]

      @sudo = options[:sudo] || ''
      @sudo = @sudo.eql?(true) ? 'sudo' : @sudo
    end

    # Call once when guard starts
    def start
      UI.info 'Guard::Passenger is running!'
      if standalone?
        @running = Runner.start_passenger(cli_start, @sudo)
      else
        true
      end
    end

    # Call with Ctrl-C signal (when Guard quit)
    def stop
      if standalone? && running?
        UI.info 'Stopping Passenger...'
        Runner.stop_passenger(cli_stop, @sudo)
      end
      true
    end

    # Call with Ctrl-Z signal
    def reload
      restart_and_ping
    end

    # Call on file(s) modifications
    def run_on_changes(paths = {})
      restart_and_ping
    end

    private

      def init_cli options={}
        cmd_parts = []
        cmd_parts << (options[:cli].nil? ? '--daemonize' : options[:cli])
        cmd_parts.join(' ')
      end

      def cli_stop
        cmd_parts = []
        cmd_parts << "--port #{port}" if port != 3000
        cmd_parts << "--pid-file #{pid_file}" if pid_file
        cmd_parts.join(' ')
      end

      def port
        if cli_start =~ /(?:-p|--port)/
          cli_start.match(/(?:-p|--port) ([^ ]+)/)[1]
        else
          '3000'
        end
      end

      def address
        if cli_start =~ /(?:-a|--address)/
          cli_start.match(/(?:-a|--address) ([^ ]+)/)[1]
        else
          '0.0.0.0'
        end
      end

      def pid_file
        if cli_start =~ /(--pid-file)/
          cli_start.match(/--pid-file ([^ ]+)/)[1]
        else
          nil
        end
      end

      def restart_and_ping
        UI.info 'Restarting Passenger...'
        restarted = Runner.restart_passenger
        Pinger.ping(address, port, notification, ping) if ping
        restarted
      end

  end
end
