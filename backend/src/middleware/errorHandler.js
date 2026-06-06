export function notFound(req, res) {
  res.status(404).json({ message: `Route not found: ${req.method} ${req.originalUrl}` });
}

export function errorHandler(error, _req, res, _next) {
  if (error.code === 11000) {
    return res.status(409).json({ message: 'A record with these values already exists' });
  }
  if (error.name === 'CastError') {
    return res.status(400).json({ message: `Invalid ${error.path}` });
  }

  const status = error.statusCode ?? 500;
  if (status >= 500) console.error(error);
  res.status(status).json({
    message: status >= 500 ? 'Internal server error' : error.message,
    ...(error.details && { details: error.details }),
  });
}
