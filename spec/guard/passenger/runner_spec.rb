require 'spec_helper'

describe Guard::Passenger::Runner do

  describe '#start_passenger' do
    context "with the passenger 3 gem installed" do
      before(:each) do
        subject.should_receive(:passenger_standalone_installed?).and_return(true)
      end

      it 'should start passenger in development environment on the port 3000' do
        subject.should_receive(:system).with('passenger start --daemonize').and_return(true)
        Guard::UI.should_receive(:info).with("Passenger standalone started.")
        subject.start_passenger('--daemonize').should be_true
      end

      it 'should start passenger in production environment on the port 3000' do
        subject.should_receive(:system).with('passenger start --daemonize --environment production').and_return(true)
        Guard::UI.should_receive(:info).with("Passenger standalone started.")
        subject.start_passenger('--daemonize --environment production').should be_true
      end

      it 'should start passenger in development environment on the port 1337' do
        subject.should_receive(:system).with('passenger start --port 1337 --daemonize').and_return(true)
        Guard::UI.should_receive(:info).with("Passenger standalone started.")
        subject.start_passenger('--port 1337 --daemonize').should be_true
      end

      it 'should start passenger under sudo if sudo option set' do
        subject.should_receive(:system).with('rvmsudo passenger start --port 80 --daemonize').and_return(true)
        Guard::UI.should_receive(:info).with("Passenger standalone started.")
        quietly { subject.start_passenger('--port 80 --daemonize', 'rvmsudo').should be_true }
      end

      it 'should fail to start passenger in development environment on the port 1' do
        subject.should_receive(:system).with('passenger start --port 1 --daemonize').and_return(false)
        Guard::UI.should_receive(:error).with("Passenger standalone failed to start!")
        quietly { subject.start_passenger('--port 1 --daemonize').should be_false }
      end
    end

    context "without the passenger 3 gem installed" do
      before(:each) do
        subject.should_receive(:passenger_standalone_installed?).and_return(false)
      end

      it 'should fail to start passenger' do
        subject.should_not_receive(:system).with('passenger start --daemonize')
        Guard::UI.should_receive(:error).with("Passenger standalone is not installed. You need at least Passenger version >= 3.0.0.\nPlease run 'gem install passenger' or add it to your Gemfile.")
        quietly { subject.start_passenger('--daemonize').should be_false }
      end
    end
  end

  describe '#passenger_standalone_installed?' do
    it 'should not have passenger >= 3 installed' do
      subject.should_receive(:gem).with("passenger", ">=3.0.0").and_raise(Gem::LoadError)
      subject.passenger_standalone_installed?.should be_false
    end

    it 'should have passenger >= 3 installed' do
      subject.should_receive(:gem).with("passenger", ">=3.0.0").and_return(true)
      subject.passenger_standalone_installed?.should be_true
    end
  end

  describe '#stop_passenger' do
    it 'should call "passenger stop --port 3000" by default' do
      subject.should_receive(:system).with('passenger stop').and_return(true)
      subject.stop_passenger('')
    end

    it 'should call "passenger stop --port 3001" if port has been changed' do
      subject.should_receive(:system).with('passenger stop --port 3001').and_return(true)
      subject.stop_passenger("--port 3001")
    end

    it 'should call "rvmsudo passenger stop --port 80" if port has been changed and sudo is set' do
      subject.should_receive(:system).with('rvmsudo passenger stop --port 80').and_return(true)
      subject.stop_passenger("--port 80", 'rvmsudo')
    end

    it 'should display info message if stop succeeds' do
      subject.should_receive(:system).with('passenger stop').and_return(true)
      Guard::UI.should_receive(:info).with("Passenger standalone stopped.")
      subject.stop_passenger('')
    end

    it 'should display error message if stop fails' do
      subject.should_receive(:system).with('passenger stop').and_return(false)
      Guard::UI.should_receive(:error).with("Passenger standalone failed to stop!")
      subject.stop_passenger('')
    end
  end

  describe '#restart_passenger' do
    it 'should call "touch tmp/restart.txt"' do
      subject.should_receive(:system).with('touch tmp/restart.txt')
      quietly { subject.restart_passenger }
    end

    context "restart succeed" do
      before(:each) { subject.should_receive(:system).with('touch tmp/restart.txt').and_return(true) }

      it 'should display a message' do
        Guard::UI.should_receive(:info).with("Passenger successfully restarted.")
        subject.restart_passenger
      end

      it 'should return true if restart succeeds' do
        subject.restart_passenger.should be_true
      end
    end

    context "restart succeed" do
      before(:each) { subject.should_receive(:system).with('touch tmp/restart.txt').and_return(false) }

      it 'should display a message' do
        Guard::UI.should_receive(:error).with("Passenger failed to restart!")
        quietly { subject.restart_passenger }
      end

      it 'should return false if restart fails' do
        quietly { subject.restart_passenger.should be_false }
      end
    end
  end

end
