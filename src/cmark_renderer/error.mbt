///|
pub(all) suberror RenderError {
  RenderError(String)
} derive(Debug)

///|
#deprecated
#doc(hidden)
pub extend RenderError with @debug.Debug::{to_repr}

///|
pub impl Show for RenderError with fn output(self, logger) {
  match self {
    RenderError(message) => {
      logger.write_string("RenderError(")
      logger.write_object(message)
      logger.write_char(')')
    }
  }
}

///|
#deprecated
#doc(hidden)
pub extend RenderError with Show::{to_string, output}
