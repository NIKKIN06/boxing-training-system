/// Mapping of a failed persistent write to the contract (REQ-NF-003,
/// AC-NF-003).
library;

import '../domain/domain_error.dart';
import '../domain/enums.dart';
import '../ports/repositories.dart';

/// Runs [write]; a [StorageWriteException] (already logged at ERROR by the
/// storage) becomes 500 STORAGE_WRITE_FAILED, and the previous state stays.
Future<T> guardStorageWrite<T>(Future<T> Function() write) async {
  try {
    return await write();
  } on StorageWriteException {
    throw const DomainError(ErrorCode.storageWriteFailed);
  }
}
