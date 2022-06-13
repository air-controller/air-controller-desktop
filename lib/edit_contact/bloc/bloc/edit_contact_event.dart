part of 'edit_contact_bloc.dart';

abstract class EditContactEvent extends Equatable {
  const EditContactEvent();

  @override
  List<Object?> get props => [];
}

class SubscriptionRequested extends EditContactEvent {
  const SubscriptionRequested();
}

class SelectedAccountChanged extends EditContactEvent {
  final Account? account;

  const SelectedAccountChanged(this.account);

  @override
  List<Object?> get props => [account];
}

class SelectedGroupChanged extends EditContactEvent {
  final ContactGroup? group;

  const SelectedGroupChanged(this.group);

  @override
  List<Object?> get props => [group];
}

class ContactFieldItemColumnOperation extends EditContactEvent {
  final bool isAdd;
  final ContactFieldItemColumn column;
  final int index;

  const ContactFieldItemColumnOperation(this.isAdd, this.column, this.index);

  @override
  List<Object?> get props => [isAdd, column, index];
}

class ContactDataTypeChanged extends EditContactEvent {
  final ContactFieldItemColumn column;
  final ContactDataType type;
  final int index;

  const ContactDataTypeChanged(this.column, this.type, this.index);

  @override
  List<Object?> get props => [column, type, index];
}

class AddCustomDataType extends EditContactEvent {
  final ContactFieldItemColumn column;
  final int index;
  final String value;

  const AddCustomDataType(this.column, this.index, this.value);

  @override
  List<Object?> get props => [column, index, value];
}

class NameValueChanged extends EditContactEvent {
  final String value;

  const NameValueChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class NoteValueChanged extends EditContactEvent {
  final String value;

  const NoteValueChanged(this.value);

  @override
  List<Object?> get props => [value];
}

class ContactFieldValueChanged extends EditContactEvent {
  final ContactFieldItemColumn column;
  final int index;
  final String value;

  const ContactFieldValueChanged(this.column, this.index, this.value);
  
  @override
  List<Object?> get props => [column, index, value];
}

class UploadPhotoRequested extends EditContactEvent {
  final File photo;

  const UploadPhotoRequested(this.photo);

  @override
  List<Object?> get props => [photo];
}

class SubmitRequested extends EditContactEvent {
  const SubmitRequested();
}