#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'rspec-puppet'
require 'facter/util/ip'
require 'facter/parse_ip'


describe 'parse_ip' do

  before do
    Facter.collection.internal_loader.load(:ipaddress)
  end

  before :each do
    Facter.fact(:hostname).stubs(:value)
    Facter.fact(:kernel).stubs(:value).returns("Linux")
  end

  def expect_ifconfig_parse(address, fixture)
    Facter::Util::IP.stubs(:exec_ifconfig).returns(my_fixture_read(fixture))
    Facter.fact(:ipaddress).value.should == address
  end

  context 'test private ip addresses' do
    Facter::Util::IP.stubs(:exec_ifconfig).returns(my_fixture_read("ifconfig_docker.txt"))
    ipaddr = '172.17.42.1'
    is_private(ipaddr).should == true
    is_private_192(ipaddr).should == false

    Facter::Util::IP.get_interfaces.each do |interface|
      puts interface
    end
  end

  context 'test localhost ip addresses' do
    ipaddr = '127.0.0.1'
    is_private(ipaddr).should == true
    is_private_192(ipaddr).should == false
  end

  context 'find networks' do
    Facter::Util::IP.stubs(:exec_ifconfig).returns(my_fixture_read("ifconfig_docker.txt"))
    puts "found net: #{find_networks}"
  end


  context 'multiple virtual interfaces' do
    it "parses correctly on Ubuntu 12.04 with Docker interface" do
      expect_ifconfig_parse "172.17.42.1", "ifconfig_docker.txt"
      #expect_ifconfig_parse "147.32.232.88", "ifconfig_docker.txt"
      #Facter.fact(:ipaddress_public).should == "147.32.232.88"
    end
  end

  context "on Linux" do
    before :each do
      Facter.fact(:kernel).stubs(:value).returns("Linux")
    end

    it "parses correctly on Ubuntu 12.04" do
      expect_ifconfig_parse "10.87.80.110", "ifconfig_ubuntu_1204.txt"
    end
  end
end