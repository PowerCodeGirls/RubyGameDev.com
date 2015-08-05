class DigestBuilder

  def self.send_daily_email
    history = DigestHistory.where(frequency: 'daily').last || DigestHistory.create_new!('daily')
    User.where(id: 1).each do |user|
    # User.daily_digest_subscribers.each do |user|
      DigestMailer.daily_digest(history, user).deliver
    end
    DigestHistory.create_new!('daily')
  end
end