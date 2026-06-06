import { ApiError } from './ApiError.js';

export function getUtcMonthRange(monthValue, yearValue) {
  const month = Number(monthValue);
  const year = Number(yearValue);

  if (!Number.isInteger(month) || month < 1 || month > 12) {
    throw new ApiError(400, 'month must be an integer from 1 to 12');
  }
  if (!Number.isInteger(year) || year < 1970 || year > 9999) {
    throw new ApiError(400, 'year must be a valid four-digit year');
  }

  return {
    start: new Date(Date.UTC(year, month - 1, 1)),
    end: new Date(Date.UTC(year, month, 1)),
  };
}
