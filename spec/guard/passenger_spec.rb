require 'spec_helper'

describe Guard::Passenger do

  describe 'options' do
    describe 'standalone' do
      it 'should be true by default' do
        subject = Guard::Passenger.new([])
        subject.should be_standalone
      end

      it 'should be true if set to true' do
        subject = Guard::Passenger.new([], { :standalone => true })
        subject.should be_standalone
      end

      it 'should be false if set so' do
        subject = Guard::Passenger.new([], { :standalone => false })
        subject.should_not be_standalone
      end
    end

    #DEPRICATED
    describe 'port' do
      it 'should not be set by default' do
        subject = Guard::Passenger.new([])
        subject.cli_start.should_not =~ /(?:-p|--port)/
      end

      it 'should be set to 1337' do
        subject = Guard::Passenger.new([], { :port => 1337 })
        subject.cli_start.should =~ /(?:-p|--port) 1337/
      end
    end

    #DEPRICATED
    describe 'env' do
      it 'should not be set by default' do
        subject = Guard::Passenger.new([])
        subject.cli_start.should_not =~ /(?:-e|--environment)/
      end

      it 'should be set to production' do
        subject = Guard::Passenger.new([], { :env => 'production' })
        subject.cli_start.should =~ /(?:-e|--environment) production/
      end
    end

    #DEPRICATED
    describe 'touch' do
      it "should display a message when passing the former :touch option" do
        Guard::UI.should_receive(:info).with("Warning: The :touch option has been replaced by the :ping option, usage is still the same.")
        Guard::Passenger.new([], { :touch => false })
      end
    end

    describe 'ping' do
      it 'should be false by default' do
        subject = Guard::Passenger.new([])
        subject.ping.should be_false
      end

      it 'should be false if set so' do
        subject = Guard::Passenger.new([], { :ping => false })
        subject.ping.should be_false
      end

      it 'should be true if set so' do
        subject = Guard::Passenger.new([], { :ping => true })
        subject.ping.should == '/'
      end

      it 'should be true if set to "foo"' do
        subject = Guard::Passenger.new([], { :ping => 'foo' })
        subject.ping.should == 'foo'
      end
    end

    describe 'sudo' do
      it 'should be blank by default' do
        subject = Guard::Passenger.new([])
        subject.sudo.should == ''
      end

      it 'should be blank if set to false' do
        subject = Guard::Passenger.new([], { :sudo => false })
        subject.sudo.should == ''
      end

      it 'should be "sudo" if set to true' do
        subject = Guard::Passenger.new([], { :sudo => true })
        subject.sudo.should == 'sudo'
      end

      it 'should be "rvmsudo" if set to "rvmsudo"' do
        subject = Guard::Passenger.new([], { :sudo => 'rvmsudo' })
        subject.sudo.should == 'rvmsudo'
      end
    end
  end

  describe 'port' do
    it 'should be 3000 if not set' do
      subject.should_receive(:cli_start).any_number_of_times.and_return('')
      subject.send(:port).should == '3000'
    end

    it 'should be 1337 if cli is set to -p 1337' do
      subject.should_receive(:cli_start).any_number_of_times.and_return('-p 1337')
      subject.send(:port).should == '1337'
    end

    it 'should be 1337 if cli is set to --port 1337' do
      subject.should_receive(:cli_start).any_number_of_times.and_return('--port 1337')
      subject.send(:port).should == '1337'
    end
  end

  describe 'address' do
    it 'should be 0.0.0.0 if not set' do
      subject.should_receive(:cli_start).any_number_of_times.and_return('')
      subject.send(:address).should == '0.0.0.0'
    end

    it 'should be me.local if cli is set to -a me.local' do
      subject.should_receive(:cli_start).any_number_of_times.and_return('-a me.local')
      subject.send(:address).should == 'me.local'
    end

    it 'should be 1337 if cli is set to --address me.local' do
      subject.should_receive(:cli_start).any_number_of_times.and_return('--address me.local')
      subject.send(:address).should == 'me.local'
    end
  end

  describe 'pid-file' do
    it 'should be nil if not set' do
      subject.should_receive(:cli_start).any_number_of_times.and_return('')
      subject.send(:pid_file).should == nil
    end

    it 'should be me.local if cli is set to --pid-file /usr/passenger.pid' do
      subject.should_receive(:cli_start).any_number_of_times.and_return('--pid-file /usr/passenger.pid')
      subject.send(:pid_file).should == '/usr/passenger.pid'
    end
  end

  describe '#start' do
    it 'should not call `passenger start\' command if standalone is disabled' do
      subject.should_receive(:standalone?).and_return(false)
      Guard::Passenger::Runner.should_not_receive(:start_passenger)
      subject.start
    end

    it 'should call `passenger start\' command if standalone is set' do
      Guard::Passenger::Runner.should_receive(:start_passenger).with('--daemonize', '').and_return(true)
      subject.start
    end

    it 'should call `passenger start -p 1337\' command if standalone is set and port is set to 1337' do
      subject.should_receive(:cli_start).and_return('--daemonize --port 1337')
      Guard::Passenger::Runner.should_receive(:start_passenger).with('--daemonize --port 1337', '').and_return(true)
      subject.start
    end

    it 'should call `passenger start -p 1337\' command if standalone is set, port is set to 1337 and environment is production' do
      subject.should_receive(:cli_start).and_return('--daemonize --port 1337 --environment production')
      Guard::Passenger::Runner.should_receive(:start_passenger).with('--daemonize --port 1337 --environment production', '').and_return(true)
      subject.start
    end

    it 'should call `rvmsudo passenger start -p 80` command if sudo is set to "rvmsudo" and port is set to 80' do
      subject = Guard::Passenger.new([], { :sudo => 'rvmsudo' })
      subject.should_receive(:cli_start).and_return('--daemonize --port 80')
      Guard::Passenger::Runner.should_receive(:start_passenger).with('--daemonize --port 80', 'rvmsudo').and_return(true)
      subject.start
    end
  end

  describe '#stop' do
    it 'should not call `passenger stop\' command if standalone is disabled' do
      subject.should_receive(:standalone?).and_return(false)
      Guard::Passenger::Runner.should_not_receive(:stop_passenger)
      subject.stop
    end

    it 'should call `passenger stop\' command if standalone is set' do
      Guard::Passenger::Runner.should_receive(:stop_passenger).and_return(true)
      subject.stop
    end

    it 'should call `passenger stop\' command if standalone is set and port is 1337' do
      subject.should_receive(:cli_stop).and_return('--port 1337')
      Guard::Passenger::Runner.should_receive(:stop_passenger).with('--port 1337', '').and_return(true)
      subject.stop
    end

    it 'should call `passenger stop\' command if standalone is set and port is 1337' do
      subject.should_receive(:cli_stop).and_return('--pid-file "/usr/passenger.pid"')
      Guard::Passenger::Runner.should_receive(:stop_passenger).with('--pid-file "/usr/passenger.pid"', '').and_return(true)
      subject.stop
    end

    it 'should call `rvmsudo passenger stop` command if standalone is set and sudo is set to "rvmsudo"' do
      subject = Guard::Passenger.new([], { :sudo => 'rvmsudo' })
      subject.should_receive(:cli_stop).and_return('--pid-file "/usr/passenger.pid"')
      Guard::Passenger::Runner.should_receive(:stop_passenger).with('--pid-file "/usr/passenger.pid"', 'rvmsudo').and_return(true)
      subject.stop
    end
  end

  %w[reload run_on_change].each do |method|
    describe "##{method}" do
      before(:each) do
        Guard::Passenger::Runner.stub(:restart_passenger)
      end

      it "should not call Pinger.ping by default" do
        Guard::Passenger::Pinger.should_not_receive(:ping)
        subject.send(method)
      end

      it 'should call `touch tmp/restart.txt\' command' do
        Guard::Passenger::Runner.should_receive(:restart_passenger)
        subject.send(method)
      end

      it 'should return true if `touch tmp/restart.txt\' command succeeds' do
        Guard::Passenger::Runner.stub(:restart_passenger).and_return(true)
        subject.send(method).should be_true
      end

      it 'should return false if `touch tmp/restart.txt\' command fails' do
        Guard::Passenger::Runner.stub(:restart_passenger).and_return(false)
        subject.send(method).should be_false
      end

      it 'should ping localhost:3000/ if ping is set to true' do
        subject = Guard::Passenger.new([], { :ping => true })
        Guard::Passenger::Pinger.should_receive(:ping).with('0.0.0.0', "3000", true, '/')
        subject.send(method)
      end

      it 'should ping localhost:3000/ if ping is set to true and notifications are disabled' do
        subject = Guard::Passenger.new([], { :ping => true, :notification => false })
        Guard::Passenger::Pinger.should_receive(:ping).with('0.0.0.0', "3000", false, '/')
        subject.send(method)
      end

      it 'should ping localhost:3000/test if ping is set to true and notifications are disabled' do
        subject = Guard::Passenger.new([], { :ping => '/test', :notification => false })
        Guard::Passenger::Pinger.should_receive(:ping).with('0.0.0.0', "3000", false, '/test')
        subject.send(method)
      end
    end
  end

end
