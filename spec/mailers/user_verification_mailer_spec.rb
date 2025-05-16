require "rails_helper"

RSpec.describe UserVerificationMailer, type: :mailer do
  describe "otp_email" do
    let(:mail) { UserVerificationMailer.otp_email }

    it "renders the headers" do
      expect(mail.subject).to eq("Otp email")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
