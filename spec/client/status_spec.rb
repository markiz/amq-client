# encoding: utf-8

require "spec_helper"
require "amq/client/status"

describe AMQ::Client::Status do
  subject do
    Class.new { include AMQ::Client::Status }.new
  end

  describe "#status=" do
    it "should be able to store status if it is in the permitted values" do
      lambda { subject.status = :opened }.should_not raise_error
    end

    it "should raise ImproperStatusError if given value isn't in the permitted values" do
      lambda { subject.status = :sleepy }.should raise_error(AMQ::Client::Status::ImproperStatusError)
    end
  end

  describe "#opened?" do
    it "should be true if the status is :opened" do
      subject.status = :opened
      subject.should be_opened
    end

    it "should be false if the status isn't :opened" do
      subject.status = :opening
      subject.should_not be_opened
    end
  end

  describe "#closed?" do
    it "should be true if the status is :closed" do
      subject.status = :closed
      subject.should be_closed
    end

    it "should be false if the status isn't :closed" do
      subject.status = :closing
      subject.should_not be_closed
    end
  end

  describe "#opening?" do
    it "should be true if the status is :opening" do
      subject.status = :opening
      subject.should be_opening
    end

    it "should be false if the status isn't :opening" do
      subject.status = :opened
      subject.should_not be_opening
    end
  end

  describe "#closing?" do
    it "should be true if the status is :closing" do
      subject.status = :closing
      subject.should be_closing
    end

    it "should be false if the status isn't :closing" do
      subject.status = :opening
      subject.should_not be_closing
    end
  end
end