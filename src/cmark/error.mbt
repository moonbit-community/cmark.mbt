///|
pub(all) suberror FolderError {
  FolderError(String)
} derive(Debug)

///|
pub impl Show for FolderError with fn output(self, logger) {
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
pub impl Show for MapperError with fn output(self, logger) {
  match self {
    MapperError(message) => {
      logger.write_string("MapperError(")
      logger.write_object(message)
      logger.write_char(')')
    }
  }
}
