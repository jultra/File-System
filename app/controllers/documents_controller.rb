class DocumentsController < ApplicationController

  def add_document
    if params[:document] != nil
	  @documents = Document.new(user_params)
	  doc = params[:id]
	  
	  if @documents.save!      
        flash[:success] = "Document added!"
	    add_author
	  end
	end
  end
  
  def edit_document_view
	@doc_id = params[:id]
	@doc = Document.find(params[:id])
	@author = Author.find(params[:id])
  end
  
  def update_document
    doc = Document.find(params[:document_id])
	doc.update(name: params[:document_name], doc_type: params[:document_type], description: params[:document_description], location: params[:document_location])
	author = Author.find(params[:document_id])
	author.update(name: params[:author_name], contact: params[:author_contact], department: params[:author_department], agency: params[:author_agency], address: params[:author_address])
	redirect_to '/view_documents'
  end
  
  def add_author
    if params[:author] != nil
	  @authors = Author.new(author_params)
	  @authors.save!
	  @event = Event.new(event_params)
	  @event.save!
	end
	
	redirect_to '/view_documents', notice: "The document has been uploaded."
  end
  
  def view_documents
    @authors = Author.all
    @documents = Document.all
	@events = Event.find_by_sql("SELECT t.doc_id, t.event_type, r.event_date FROM (SELECT doc_id, event_type, MAX(event_date) as event_date FROM events group by doc_id) r INNER JOIN events t ON t.doc_id AND t.event_date = r.event_date")
  end
  
  def delete_document
    @doc = Document.find(params[:id])
	@author = Author.find(params[:id])
	event = Event.where(:doc_id => params[:id])
	
	Document.delete(@doc)
	Author.delete(@author)
	Event.delete(event.ids)
	
	redirect_to '/view_documents'
  end
  
  def user_params
    params.require(:document).permit(:name, :description, :location, :doc_type, attachments_attributes: [:attachment, :doc_id])
  end
  
  def author_params
	params.require(:author).permit(:name, :contact, :department, :agency, :address)
  end
  
  def event_params
	params.require(:event).permit(:doc_id, :event_date, :event_type, :remarks)
  end
  
end
