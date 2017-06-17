class EmailList

  # this version works with Brian Getting's Hominid gem:
  #  script/plugin install git://github.com/bgetting/hominid.git

  cattr_accessor :errors

  private

  @@hominid = nil
  @@list = nil
  @@listid = nil

  def self.hominid ; @@hominid ; end
  
  def self.segment_id_from_name(name)
    self.init_hominid || return
    hominid.static_segments(@@listid).detect { |s| s['name'] == name }['id']
  end

  public

  def self.disabled?
    Figaro.env.email_integration != 'MailChimp'
  end

  def self.enabled? ; !self.disabled? ; end

  def self.init_hominid
    logger.info("NOT initializing mailchimp") and return nil if self.disabled?
    return true if hominid
    apikey = Figaro.env.mailchimp_key
    @@list = Option.mailchimp_default_list_name
    if (apikey.blank? || @@list.blank?)
      logger.warn("NOT using Mailchimp, one or more necessary options are blank")
      return nil
    end
    begin
      @@hominid = Hominid::Base.new :api_key => apikey
      @@listid = hominid.find_list_id_by_name(@@list)
    rescue NoMethodError => e   # dereference nil.[] means list not found
      logger.warn "Init Mailchimp: list '#{@@list}' not found"
      return nil
    rescue StandardError => e
      logger.info "Init Mailchimp failed: <#{e.message}>"
      return nil
    end
    logger.info "Init Mailchimp with default list '#{@@list}'"
    return true
  end

  def self.subscribe(cust, email=cust.email)
    self.init_hominid || return
    logger.info "Subscribe #{cust.full_name} as #{email}"
    msg = "Subscribing #{cust.full_name} <#{email}> to '#{@@list}'"
    begin
      hominid.subscribe(
        @@listid,
        email,
        {:FNAME => cust.first_name, :LNAME => cust.last_name},
        {:email_type => 'html'})
      logger.info msg
    rescue Exception => e
      logger.info [msg,e.message].join(': ')
    end
  end

  def self.update(cust, old_email)
    self.init_hominid || return
    logger.info "Update email for #{cust.full_name} from #{old_email} to #{cust.email}"
    begin
      # update existing entry
      msg = "Changing <#{old_email}> to <#{cust.email}> " <<
        "for #{cust.full_name} in  '#{@@list}'"
      hominid.update_member(
        @@listid,
        old_email,
        {:FNAME => cust.first_name, :LNAME => cust.last_name,
          :email => cust.email })
    rescue Hominid::ListError => e
      if (e.message !~ /no record of/i)
        msg = "Hominid error: #{e.message}"
      else
        begin
          # was not on list previously
          msg = "Adding #{cust.email} to list #{@@list}"
          hominid.subscribe(@@listid, cust.email,
            {:FNAME => cust.first_name, :LNAME => cust.last_name},
            {:email_type => 'html'})
        rescue Exception => e
          throw e
        end
      end
      # here if all went well...
      logger.info msg
    rescue Exception => e
      logger.info [msg,e.message].join(': ')
    end
  end

  def self.unsubscribe(cust, email=cust.email)
    self.init_hominid || return
    logger.info "Unsubscribe #{cust.full_name} as #{email}"
    msg = "Unsubscribing #{cust.full_name} <#{email}> from '#{@@list}'"
    begin
      hominid.unsubscribe(@@listid, email)
      logger.info msg
    rescue Exception => e
      logger.info [msg,e.message].join(': ')
    end
  end

  def self.create_sublist_with_customers(name, customers)
    self.create_sublist(name) && self.add_to_sublist(name, customers)
  end

  def self.create_sublist(name)
    self.init_hominid || return
    begin
      hominid.add_static_segment(@@listid, name)
      return true
    rescue Exception => e
      error = "List segment '#{name}' could not be created: #{e.message}"
      logger.warn error
      self.errors = error
      return nil
    end
  end

  def self.get_sublists
    # returns array of 2-element arrays, each of which is [name,count] for static segments
    self.init_hominid || (return([]))
    begin
      segs = hominid.static_segments(@@listid).map { |seg| [seg['name'], seg['member_count']] }
      puts "Returning static segments: #{segs}"
      segs
    rescue Exception => e
      logger.info "Getting sublists: #{e.message}"
      []
    end
  end

  def self.add_to_sublist(sublist,customers=[])
    self.init_hominid || return
    begin
      seg_id = segment_id_from_name(sublist)
      emails = customers.select { |c| c.valid_email_address? }.map { |c| c.email }
      if emails.empty?
        self.errors = "None of the matching customers had valid email addresses."
        return 0
      end
      result = hominid.static_segment_add_members(@@listid, seg_id, emails)
      if !result['errors'].blank?
        self.errors = "MailChimp was unable to add #{result['errors'].length} of the customers, usually because they aren't subscribed to the master list."
      end
      return result['success'].to_i
    rescue Exception => e
      self.errors = e.message
      RAILS_DEFAULT_LOGGER.info "Adding #{customers.length} customers to sublist '#{sublist}': #{e.message}"
      return 0
    end
  end

end
