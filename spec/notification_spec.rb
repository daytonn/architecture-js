require "spec_helper"

describe ArchitectureJS::Notification do  
  it 'should have a notify method' do
    ArchitectureJS::Notification.notify(:none, 'hello').should == 'hello'
  end
  
  it 'should have a notice method' do
    ArchitectureJS::Notification.notice('hello').should === 'hello'
  end
  
  it 'should have a log method' do
    ArchitectureJS::Notification.log('hello').should === "\e[32m>>>\e[0m hello"
  end
  
  it 'should have an event method' do
    ArchitectureJS::Notification.event('hello').should === "\e[33m<<<\e[0m hello"
  end
  
  it 'should have an added method' do
    ArchitectureJS::Notification.added('hello').should === "\e[32m+++\e[0m hello"
  end
  
  it 'should have an error method' do
    ArchitectureJS::Notification.error('hello').should === "\e[0;31m!!!\e[0m hello"
  end
end