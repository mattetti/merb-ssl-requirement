# Copyright (c) 2005 David Heinemeier Hansson
# Copyright (c) 2008 Steve Tooke
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
module SslRequirement
  def self.included(controller)
    controller.extend(ClassMethods)
    controller.before(:ensure_proper_protocol)
  end

  module ClassMethods
    # Specifies that the named actions requires an SSL connection to be performed (which is enforced by ensure_proper_protocol).
    def ssl_required(*actions)
      # write_inheritable_array(:ssl_required_actions, actions)
      self.ssl_required_actions.push(*actions)
    end

    def ssl_allowed(*actions)
      # write_inheritable_array(:ssl_allowed_actions, actions)
      self.ssl_allowed_actions.push(*actions)
    end
    
    def ssl_required_actions
      @ssl_required_actions ||= []
    end
    
    def ssl_allowed_actions
      @ssl_allowed_actions ||= []
    end
  end
  
  protected
    # Returns true if the current action is supposed to run as SSL
    def ssl_required?
      # (self.class.read_inheritable_attribute(:ssl_required_actions) || []).include?(action_name.to_sym)
      self.class.ssl_required_actions.include?(action_name.to_sym)
    end
    
    def ssl_allowed?
      self.class.ssl_allowed_actions.include?(action_name.to_sym)
      # (self.class.read_inheritable_attribute(:ssl_allowed_actions) || []).include?(action_name.to_sym)
    end

  private
    def ensure_proper_protocol
      return true if ssl_allowed?
      
      if ssl_required? && !request.ssl?
        throw :halt, redirect("https://" + request.host + request.uri)
      elsif request.ssl? && !ssl_required?
        throw :halt, redirect("http://" + request.host + request.uri)
      end
    end
end