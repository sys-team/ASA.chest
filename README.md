ASA.chest
===========

chest
------------

Service accepts XML data in ASA.rest format and store it in the database tables.
Empty post returns setting for "STGeotracking" iOS application, based on defaults or UOAuth role "STGTSettings" data.

### Tables

* ch.entity - entity data
* ch.relationship - relationships between the entities from ch.entity
* ch.attribute - parsed attibutes for entityes


### Stored procedures

* ch.createSP(@entity long varchar default null) - creates the stored procedure with owner 'ch' and name = @entity. Procedure result set is parsed entity fields for all record in the table ch.entity named @entity.

*  ch.createView(@entity long varchar default null) - creates the view with owner 'ch' and name = @entity. View represents parsed entity fields for all record in the table ch.entity named @entity.



### XML example

	<?xml version="1.0"?> 
	<post xmlns="https://github.com/sys-team/ASA.chest">
		<d name="Entity1" xid="13C8B00D-2D73-470A-B97C-6F0FAC11290B">
			<date name="date">2013-04-19 07:32:45 +0000</date>
			<string name="name">Name</string>
			<d name="Entity2" xid="A49E11BF-2450-4A08-BAC7-CF31199C464E"/>
		</d>
	</post>