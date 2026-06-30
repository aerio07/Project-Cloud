<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Contracts\Validation\Validator;
use Illuminate\Http\Exceptions\HttpResponseException;

class StorePlaceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id'         => ['required', 'integer', 'exists:categories,id'],
            'name'                => ['required', 'string', 'max:255'],
            'address'             => ['required', 'string', 'max:500'],
            'latitude'            => ['required', 'numeric', 'between:-90,90'],
            'longitude'           => ['required', 'numeric', 'between:-180,180'],
            'description'         => ['nullable', 'string'],
            'rating'              => ['nullable', 'numeric', 'between:0,5'],
            'photo_url'           => ['nullable', 'string', 'max:2048'],
            'opening_hours'       => ['required', 'string', 'max:255'],

            // Facilities
            'facility_ids'        => ['required', 'array', 'min:1'],
            'facility_ids.*'      => ['integer', 'distinct', 'exists:facilities,id'],

            // Fuels
            'fuels'               => ['required', 'array', 'min:1'],
            'fuels.*.id'          => ['required', 'integer', 'distinct', 'exists:fuels,id'],
            'fuels.*.price'       => ['required', 'numeric', 'min:0'],
            'fuels.*.is_available'=> ['required', 'boolean'],
        ];
    }

    public function messages(): array
    {
        return [
            'fuels.*.id.exists'         => 'One of the fuel ids does not exist.',
            'facility_ids.*.exists'     => 'One of the facility ids does not exist.',
            'fuels.*.id.distinct'       => 'Duplicate fuel id detected.',
            'facility_ids.*.distinct'   => 'Duplicate facility id detected.',
        ];
    }

    /**
     * Return JSON 422 instead of redirect on validation failure.
     */
    protected function failedValidation(Validator $validator)
    {
        throw new HttpResponseException(
            response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors'  => $validator->errors(),
            ], 422)
        );
    }
}
