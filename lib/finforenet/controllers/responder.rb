module Finforenet
  module Controllers 
    module Responder
      extend ActiveSupport::Concern
      
      included do
	      respond_to :xml, :json
	      include InstancesMethods
      end

      module ClassMethods
      end
      
      module InstancesMethods
	
				private 
				
				  def api_responds(*args, &block)
				  	respond_with(*args) do |format|
				  		format.any(*navigational_formats, &block)
				  	end
				  end
				  
				  def navigational_formats
				  	@navigational_formats ||= [:html]
				  end
				  
				  def is_navigational_format?
				  	["*/*", :html].include?(request_format)
				  end
				  
				  def error_responds(opts)
					  errors = opts.is_a?(Hash) ? [opts[:error]] : opts.errors.full_messages
					  respond_to do |format|
						  format.json { render :json => {:errors => errors}, :status => :unprocessable_entity }
						  format.xml  { render :xml  => {:errors => errors}, :status => :unprocessable_entity }
						end
					end
				
				  def error_object(message = "Invalid Access")
				    {:error => message}
				  end
			
				  def accident_alert(message)
				    respond_to do |format|
					  respond_to_do(format, error_object(message))
				    end
				  end
				  
				  def display_rescue(e)
				    accident_alert( (is_authentic ? e.to_s : ERR_AUTH) )    
				  end
			
				  def respond_to_do(format, response, status = 200)
			      key = response.respond_to?('keys') ? response[response.keys.first] : "ok"
				    format.html { response[:url].blank? ? (render :text => key) : (redirect_to response[:url]) }
				    supported_formats(format, response, status)
				  end
				  
				  def supported_formats(format, response, status = 200)
				    format.json { render :json => response, :status => status, :head => :ok}
				    format.xml  { render :xml  => response, :status => status, :head => :ok}
				  end
			
				  def respond_error_to_do(format, response)
				    respond_to_do(format, response.errors, :unprocessable_entity)
				  end
				  
				  def is_authentic
				    current_user || params[:auth_token] || params[:finfore_token]
				  end
      end
      
    end
  end
end
