///|
pub(all) suberror FolderError {
  FolderError(String)
} derive(Debug)

///|
#deprecated
#doc(hidden)
pub extend FolderError with @debug.Debug::{to_repr}

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
#deprecated
#doc(hidden)
pub extend FolderError with Show::{to_string, output}

///|
pub(all) suberror MapperError {
  MapperError(String)
} derive(Debug)

///|
#deprecated
#doc(hidden)
pub extend MapperError with @debug.Debug::{to_repr}

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

///|
#deprecated
#doc(hidden)
pub extend MapperError with Show::{to_string, output}
