@tool
class_name ResourceSet
extends CustomResource
## A resource that stores mutltiple resources of a specified type.
##
## Assign to exported variable in any class to provide a specified type of resources.[br]
## All resources assigned to a [member resource_set] must have a [member Resource.resource_name] set in the inspector.

## Defines the custom type of the resources that should be included in the ResourceSet.
## Won't take effect before [member register_type] is set to [param true].[br]
## Editing this variable will delete the content of the ResourceSet to prevent type errors and
## [member register_type] will be available again then.
@export var type_name: StringName:
	set(value):
		if register_type == true:
			notify_property_list_changed()
			resource_set = []
			register_type = false
			type_name = ""
		else:

			type_name = value

## Set to [param true] to register the [member type_name]. Before the type is registered [member resource_set] is set to read-only.
@export var register_type : bool:
	set(value):
		notify_property_list_changed()
		register_type = value

## The resources included in the ResourceSet. Won't be available before registering a type.
@export var resource_set: Array[Resource]:
	set(value):
		resource_set = value
		if not resource_set.is_empty():
			for i: Resource in resource_set:
				if i != null and i.resource_name.is_empty():
					print("{} : the 'resource_name' hasn't been set for this resource".format([i, self.type_name], "{}"))

## A debug_resource that will be returned if a requested_resource hasn't been found.
@export var debug_resource: Resource:
	set(value):
		debug_resource = value
		notify_property_list_changed()
	get:
		if debug_resource == null:
			if not Engine.is_editor_hint():
				printerr("The debug_resource for the ResourceSet {} hasn't been set.".format([self.type_name], "{}"))
			return null
		else:
			return debug_resource

## The method that sould be called to get a resource from a ResourceSet, take the [member Resource.resource_name] as argument.
func grab(_name: String) -> Resource:
		if not resource_set.is_empty() :
			for i : Resource in resource_set:
				if _name == i.resource_name:
					return i
			printerr("The resource requested wasn't found in {}. Returning default debug_resource instead.".format([self.type_name], "{}"))
			return debug_resource
		else:
			printerr("The resource_set {} is empty. Returning dafault debug_resource instead.".format([self.type_name], "{}"))
			return debug_resource

func _validate_property(property: Dictionary) -> void:
	if property.name not in ["type_name", "register_type", "debug_resource"]:
		if type_name.is_empty() or debug_resource == null:
			property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "resource_set" :
		property.hint_string = "24/17:" + type_name

	if property.name == "register_type" and register_type == true:
		property.usage |= PROPERTY_USAGE_READ_ONLY

	if property.name == "debug_resource":
		property.hint_string = type_name
