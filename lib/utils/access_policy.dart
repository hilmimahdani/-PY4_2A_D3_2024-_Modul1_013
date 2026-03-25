class AccessPolicy {

  static bool canEditOrDelete({
    required String currentUserId,   
    required String logOwnerId,      
  }) {
   
    return currentUserId == logOwnerId;
  }

  
  @deprecated
  static bool canEditOrDeleteByRole({
    required String currentUserRole, 
    required String currentUserId,
    required String logOwnerId,
  }) {
    if (currentUserRole == 'Ketua') {
      return true;
    }
    if (currentUserRole == 'Anggota' && currentUserId == logOwnerId) {
      return true;
    }
    return false;
  }
}