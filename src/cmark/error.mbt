///|
pub(all) suberror FolderError {
  FolderError(String)
} derive(Debug)

///|
pub impl Show for FolderError with output(self, logger) {
  match self {
    FolderError(message) => {
      logger.write_string("FolderError(")
      logger.write_object(message)
      logger.write_char(')')
    }
  }
}

///|
pub(all) suberror MapperError {
  MapperError(String)
} derive(Debug)

///|
pub impl Show for MapperError with output(self, logger) {
  match self {
    MapperError(message) => {
      logger.write_string("MapperError(")
      logger.write_object(message)
      logger.write_char(')')
    }
  }
}
