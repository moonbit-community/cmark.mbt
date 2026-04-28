///|
pub(all) suberror RenderError {
  RenderError(String)
} derive(Debug)

///|
pub impl Show for RenderError with output(self, logger) {
  match self {
    RenderError(message) => {
      logger.write_string("RenderError(")
      logger.write_object(message)
      logger.write_char(')')
    }
  }
}
